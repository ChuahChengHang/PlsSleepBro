//
//  SleepView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 20/11/25.
//

import SwiftUI
import SwiftData
import UIKit
import AVFoundation
import Combine

struct SleepView: View {
    @Environment(\.modelContext) private var context
    @Binding var showSleepView: Bool
    @Binding var sleepTime: Date
    @State private var showGuidedAccessSheet: Bool = false
    @StateObject var permissionModel = PermissionModel()
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
                .frame(height: 40)
            VisionView()
            MicrophoneView()
            
            Text("Sleep Time")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.red)
            
            Button {
                let calendar = Calendar.current
                
                let sleepComponents = calendar.dateComponents([.day, .hour, .minute], from: sleepTime)
                let wakeComponents = calendar.dateComponents([.day, .hour, .minute], from: Date())
                
                var wakeMinutes = wakeComponents.hour! * 60 + wakeComponents.minute!
                var sleepMinutes = sleepComponents.hour! * 60 + sleepComponents.minute!
                
                if wakeComponents.day! > sleepComponents.day! {
                    wakeMinutes = ((wakeComponents.hour! + 24) * 60) + wakeComponents.minute!
                }
                
                let minutesSlept = wakeMinutes - sleepMinutes
                let hours = Double(minutesSlept) / 60.0
                
                let entry = sleepDurationStruct(date: .now, duration: hours)
                context.insert(entry)
                
                do {
                    try context.save()
                    print("Hours: \(entry.duration)")
                } catch {
                    print(error)
                }
                
                withAnimation { showSleepView = false }
            }label: {
                Text("Wake Up Now")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 200, height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(.red)
                            .shadow(radius: 8, y: 4)
                    )
            }
            .glassEffect(in: RoundedRectangle(cornerRadius: 22))
            .padding(.top, 4)
            VStack(alignment: .leading) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(permissionModel.guidedAccess ? .green : .red)
                        .frame(width: 12, height: 12)
                    
                    Text("Guided Access: \(permissionModel.guidedAccess ? "On" : "Off")")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                HStack(spacing: 8) {
                    Circle()
                        .fill(permissionModel.microphone ? .green : .red)
                        .frame(width: 12, height: 12)
                    
                    Text("Microphone: \(permissionModel.microphone ? "On" : "Off")")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                HStack(spacing: 8) {
                    Circle()
                        .fill(permissionModel.camera ? .green : .red)
                        .frame(width: 12, height: 12)
                    
                    Text("Camera: \(permissionModel.camera ? "On" : "Off")")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text("Tips for Sleeping")
                        .font(.title3.bold())
                }
                
                Text("- Enable guided access so we can track light and noise data during sleep.")
                Text("- Make sure camera + microphone permissions are granted before starting.")
                Text("- Keep your back camera facing upward for accurate light tracking.")
            }
            .padding()
            .background(.white.opacity(0.09))
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .preferredColorScheme(.dark)
        .padding(.bottom, 30)
        .preferredColorScheme(.dark)
    }
}


#Preview {
    SleepView(showSleepView: .constant(false), sleepTime: .constant(Date.now))
}

class PermissionModel: ObservableObject {
    @Published var guidedAccess: Bool = UIAccessibility.isGuidedAccessEnabled
    @Published var microphone: Bool = false
    @Published var camera: Bool = false
    
    private let cameraModel = CameraViewModel()
    
    private var guidedAccessObserver: NSObjectProtocol?
    private var microphoneTimer: Timer?
    private var cameraTimer: Timer?
    
    init() {
        startGuidedAccessMonitoring()
        startMicrophoneMonitoring()
        startCameraMonitoring()
    }
    
    deinit {
        microphoneTimer?.invalidate()
        cameraTimer?.invalidate()
        if let observer = guidedAccessObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    
    
    private func startGuidedAccessMonitoring() {
        guidedAccessObserver = NotificationCenter.default.addObserver(
            forName: UIAccessibility.guidedAccessStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.guidedAccess = UIAccessibility.isGuidedAccessEnabled
        }
    }
    
    
    
    private func startMicrophoneMonitoring() {
        microphoneTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            switch AVAudioSession.sharedInstance().recordPermission {
            case .granted:
                self.microphone = true
            default:
                self.microphone = false
            }
        }
    }
    private func startCameraMonitoring() {
        cameraTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self else { return }

            let status = AVCaptureDevice.authorizationStatus(for: .video)

            switch status {
            case .authorized:
                self.camera = true
            default:
                self.camera = false
            }
        }
    }
}

