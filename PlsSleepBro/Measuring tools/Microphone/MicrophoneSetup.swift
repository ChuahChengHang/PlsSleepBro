//
//  MicrophoneSetup.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 19/11/25.
//

import Foundation
import AVFoundation
import Combine


@MainActor
final class NoiseMonitor: ObservableObject {
    enum PermissionState {
        case undetermined
        case granted
        case denied
        case failed(String)
    }
    
    @Published var permissionState: PermissionState = .undetermined
    @Published var normalizedLevel: Double = 0.0   // 0 (quiet) → 1 (loud)
    @Published var decibelLevel: Double = -160     // Raw dBFS value for reference
    
    private let audioEngine = AVAudioEngine()
    private let session = AVAudioSession.sharedInstance()
    private let processingQueue = DispatchQueue(label: "NoiseMonitorQueue")
    
    func startMonitoring() {
        switch session.recordPermission {
        case .undetermined:
            session.requestRecordPermission { [weak self] allowed in
                guard let self else { return }
                Task { @MainActor in
                    if allowed {
                        self.permissionState = .granted
                        self.configureAndStartEngine()
                    } else {
                        self.permissionState = .denied
                    }
                }
            }
        case .granted:
            permissionState = .granted
            configureAndStartEngine()
        case .denied:
            permissionState = .denied
        @unknown default:
            permissionState = .failed("Unknown microphone permission state.")
        }
    }
    
    nonisolated func stopMonitoring() {
        processingQueue.async { [weak self] in
            guard let self else { return }
            if self.audioEngine.isRunning {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
            }
        }
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func configureAndStartEngine() {
        processingQueue.async { [weak self] in
            guard let self else { return }
            
            do {
                try self.session.setCategory(.playAndRecord,
                                             mode: .measurement,
                                             options: [.duckOthers, .allowBluetooth])
                try self.session.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                Task { @MainActor in
                    self.permissionState = .failed("Unable to configure audio session: \(error.localizedDescription)")
                }
                return
            }
            
            let inputNode = self.audioEngine.inputNode
            let bus = 0
            inputNode.removeTap(onBus: bus)
            let format = inputNode.outputFormat(forBus: bus)
            
            inputNode.installTap(onBus: bus, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                self?.process(buffer: buffer)
            }
            
            do {
                try self.audioEngine.start()
            } catch {
                Task { @MainActor in
                    self.permissionState = .failed("Unable to start audio engine: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func process(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        if frameLength == 0 {
            return
        }
        
        var sum: Float = 0
        for frame in 0..<frameLength {
            sum += channelData[frame] * channelData[frame]
        }
        let rms = sqrt(sum / Float(frameLength))
        let level = 20 * log10(rms)
        let clampedLevel = max(-100, min(0, level))
        let normalized = max(0, min(1, (clampedLevel + 100) / 100))
        let displayLevel = Double(clampedLevel)
        let displayNormalized = Double(normalized)
        
        Task { @MainActor in
            self.decibelLevel = displayLevel
            self.normalizedLevel = displayNormalized
        }
    }
}
