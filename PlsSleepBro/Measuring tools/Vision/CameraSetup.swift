//
//  CameraSetup.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 19/11/25.
//

import Foundation
import Combine
import AVFoundation
import CoreImage
import CoreGraphics

final class CameraViewModel: NSObject, ObservableObject {
    @Published var authorizationStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @Published var statusMessage: String = "Requesting camera access..."
    @Published var isSessionRunning = false
    @Published var latestLuminance: Double?

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let photoOutput = AVCapturePhotoOutput()
    private var captureTimer: Timer?
    private let ciContext = CIContext()

    func start() {
        checkAuthorization()
    }

    func stop() {
        invalidateTimer()
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
        DispatchQueue.main.async {
            self.isSessionRunning = false
            self.statusMessage = "Camera paused"
        }
    }

    private func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorizationStatus = .authorized
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationStatus = granted ? .authorized : .denied
                }
                if granted {
                    self?.configureSession()
                } else {
                    DispatchQueue.main.async {
                        self?.statusMessage = "Camera access is required"
                    }
                }
            }
        case .restricted, .denied:
            DispatchQueue.main.async {
                self.authorizationStatus = .denied
                self.statusMessage = "Enable camera access in Settings"
            }
        @unknown default:
            DispatchQueue.main.async {
                self.authorizationStatus = .denied
                self.statusMessage = "Camera access unavailable"
            }
        }
    }

    private func configureSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            // Remove previous inputs if the session is being reconfigured.
            self.session.inputs.forEach { self.session.removeInput($0) }

            guard
                let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                let cameraInput = try? AVCaptureDeviceInput(device: camera),
                self.session.canAddInput(cameraInput)
            else {
                DispatchQueue.main.async {
                    self.statusMessage = "Unable to access the back camera"
                }
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(cameraInput)

            if self.session.canAddOutput(self.photoOutput) {
                self.photoOutput.isHighResolutionCaptureEnabled = true
                self.session.addOutput(self.photoOutput)
            } else {
                DispatchQueue.main.async {
                    self.statusMessage = "Unable to capture photos"
                }
                self.session.commitConfiguration()
                return
            }

            self.session.commitConfiguration()
            self.startSessionIfNeeded()
        }
    }

    private func startSessionIfNeeded() {
        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async {
                self.isSessionRunning = true
                self.statusMessage = "Measuring luminance every minute"
                self.scheduleTimer()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.capturePhoto()
            }
        }
    }

    private func scheduleTimer() {
        DispatchQueue.main.async {
            self.captureTimer?.invalidate()
            self.captureTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
                self?.capturePhoto()
            }
            if let captureTimer = self.captureTimer {
                RunLoop.main.add(captureTimer, forMode: .common)
            }
        }
    }

    private func invalidateTimer() {
        DispatchQueue.main.async {
            self.captureTimer?.invalidate()
            self.captureTimer = nil
        }
    }

    private func capturePhoto() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.flashMode = .off
            photoSettings.isAutoStillImageStabilizationEnabled = true

            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    private static func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: Date())
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            DispatchQueue.main.async {
                self.statusMessage = "Capture failed: \(error.localizedDescription)"
            }
            return
        }

        guard
            let data = photo.fileDataRepresentation(),
            let ciImage = CIImage(data: data)
        else {
            DispatchQueue.main.async {
                self.statusMessage = "Capture failed: Invalid image data"
            }
            return
        }

        let extent = ciImage.extent
        guard let averageFilter = CIFilter(name: "CIAreaAverage") else {
            DispatchQueue.main.async {
                self.statusMessage = "Capture failed: Filter unavailable"
            }
            return
        }
        averageFilter.setValue(ciImage, forKey: kCIInputImageKey)
        averageFilter.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)

        guard let outputImage = averageFilter.outputImage else {
            DispatchQueue.main.async {
                self.statusMessage = "Capture failed: Unable to compute luminance"
            }
            return
        }

        var pixel = [UInt8](repeating: 0, count: 4)
        ciContext.render(
            outputImage,
            toBitmap: &pixel,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        let r = Double(pixel[0]) / 255.0
        let g = Double(pixel[1]) / 255.0
        let b = Double(pixel[2]) / 255.0
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b

        DispatchQueue.main.async {
            self.latestLuminance = luminance
            self.statusMessage = "Last sample: \(Self.formattedTimestamp())"
        }
    }
}
