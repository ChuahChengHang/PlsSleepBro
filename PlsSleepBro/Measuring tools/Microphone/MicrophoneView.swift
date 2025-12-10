//
//  MicrophoneView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 19/11/25.
//

import SwiftUI
import SwiftData

struct MicrophoneView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var monitor = NoiseMonitor()
    @State private var saveTask: Task<Void, Never>? = nil
    private var status: (title: String, description: String, color: Color) {
        let value = monitor.normalizedLevel
        switch value {
        case ..<0.35:
            return ("Quiet", "Great environment for sleep.", .green)
        case 0.35..<0.7:
            return ("Moderate", "Acceptable for conversation, but could get distracting.", .yellow)
        default:
            return ("Loud", "Consider lowering the volume or moving to another room.", .red)
        }
    }
    
    private var decibelText: String {
        if monitor.decibelLevel <= -95 {
            return "Silence"
        }
        return String(format: "%.1f dBFS", monitor.decibelLevel)
    }
    
    var body: some View {
//        VStack(alignment: .leading, spacing: 28) {
//            Text("Room Noise")
//                .font(.largeTitle.bold())
//            
//            switch monitor.permissionState {
//            case .denied:
//                permissionMessage(
//                    systemImage: "microphone.slash",
//                    title: "Microphone access denied",
//                    message: "Enable microphone access in Settings > Privacy > Microphone to monitor the room noise."
//                )
//            case .failed(let reason):
//                permissionMessage(
//                    systemImage: "exclamationmark.triangle",
//                    title: "Something went wrong",
//                    message: reason
//                )
//            default:
//                liveMonitorView
//            }
//            
//            Spacer()
//        }
//        .padding(28)
//        .background(Color(.systemBackground))
        VStack {
        }
        .onAppear {
            monitor.startMonitoring()

            saveTask = Task {
                while !Task.isCancelled {
                    do {
                        let positiveNoise = max(0, monitor.decibelLevel + 70)
                        let noiseEntry = noiseStruct(date: Date(), noise: positiveNoise)

                        context.insert(noiseEntry)

                        do {
                            try context.save()
                            print("Saved noise:", positiveNoise)
                        } catch {
                            print("Failed to save noise:", error)
                        }

                        try await Task.sleep(nanoseconds: 2_000_000_000)
                    } catch {
                        print("Task sleep or noise save failed:", error)
                        break
                    }
                }
            }
        }

        .onDisappear {
            saveTask?.cancel()
            monitor.stopMonitoring()
        }
    }
    
    private var liveMonitorView: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Current level")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(decibelText)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
            }
            
            LevelBarsView(level: monitor.normalizedLevel, tint: status.color)
                .frame(height: 160)
                .animation(.easeOut(duration: 0.2), value: monitor.normalizedLevel)
            
            HStack(spacing: 16) {
                Image(systemName: "ear")
                    .font(.title2)
                    .foregroundStyle(status.color)
                VStack(alignment: .leading, spacing: 4) {
                    Text(status.title)
                        .font(.headline)
                        .foregroundStyle(status.color)
                    Text(status.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func permissionMessage(systemImage: String, title: String, message: String) -> some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct LevelBarsView: View {
    let level: Double
    let tint: Color
    private let barCount = 10
    
    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 12
            let totalSpacing = spacing * CGFloat(barCount - 1)
            let barWidth = max(10, (proxy.size.width - totalSpacing) / CGFloat(barCount))
            
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    let progress = Double(index + 1) / Double(barCount)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(progress <= level ? tint : Color.gray.opacity(0.25))
                        .frame(width: barWidth,
                               height: barHeight(for: progress, totalHeight: proxy.size.height))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.black.opacity(progress <= level ? 0.15 : 0.05), lineWidth: 1)
                        )
                }
            }
        }
    }
    
    private func barHeight(for progress: Double, totalHeight: CGFloat) -> CGFloat {
        let baseHeight = totalHeight * 0.25
        let dynamicHeight = totalHeight * 0.65 * progress
        return baseHeight + dynamicHeight
    }
}

#Preview {
    MicrophoneView()
}

