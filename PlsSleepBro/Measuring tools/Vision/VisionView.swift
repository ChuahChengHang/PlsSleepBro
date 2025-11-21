//
//  VisionView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 19/11/25.
//

import SwiftUI
import AVFoundation
import SwiftData

struct VisionView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = CameraViewModel()
    var body: some View {
        //        ZStack(alignment: .bottom) {
        //            CameraPreviewView(session: viewModel.session)
        //                .ignoresSafeArea()
        //                .overlay {
        //                    if viewModel.authorizationStatus != .authorized {
        //                        Color.black
        //                            .opacity(0.75)
        //                            .ignoresSafeArea()
        //                    }
        //                }
        //
        //            VStack(spacing: 8) {
        //                Text(viewModel.statusMessage)
        //                    .font(.headline)
        //                    .multilineTextAlignment(.center)
        //
        //                if viewModel.authorizationStatus != .authorized {
        //                    Text("Grant camera permission in Settings so the app can sample a photo every minute for luminance.")
        //                        .font(.footnote)
        //                        .multilineTextAlignment(.center)
        //                } else {
        //                    Text("The back camera samples a frame every minute, computes luminance locally, and discards the image.")
        //                        .font(.footnote)
        //                        .multilineTextAlignment(.center)
        //                }
        //            }
        //            .padding()
        //            .background(.thinMaterial)
        //            .cornerRadius(16)
        //            .padding()
        //        }
        VStack {
            if let luminance = viewModel.latestLuminance {
                let percentage = String(format: "%.1f", luminance * 100)
                let absolute = String(format: "%.3f", luminance)
                VStack {
//                    Text("Relative luminous intensity: \(percentage)%")
//                        .font(.title3.bold())
//                    Text("Luminous intensity (normalized 0-1): \(absolute)")
//                        .font(.footnote)
                }
                .task {
                    Task {
                        let lux = luminance * 10
                        let entry = lightStruct(date: Date.now, light: lux)
                        context.insert(entry)
                        do {
                            print(lux)
                            try context.save()
                        }catch {
                            print("error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

#Preview {
    VisionView()
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let previewLayer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Failed to create AVCaptureVideoPreviewLayer")
        }
        return previewLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        videoPreviewLayer.videoGravity = .resizeAspectFill
    }
}

