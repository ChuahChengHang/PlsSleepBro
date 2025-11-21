//
//  SleepView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 20/11/25.
//

import SwiftUI
import SwiftData
import UIKit

struct SleepView: View {
    @Environment(\.modelContext) private var context
    @State private var isGuidedAccessActive: Bool = UIAccessibility.isGuidedAccessEnabled
    @Binding var showSleepView: Bool
    @Binding var sleepTime: Date
    var body: some View {
        VStack {
            VisionView()
            MicrophoneView()
            Text("Sleep Time")
                .foregroundStyle(.red)
                .font(.largeTitle)
            Text("Guided Access Status: \(isGuidedAccessActive ? "Active" : "Inactive")")
                .padding()
            Button {
                let calendar = Calendar.current
                let sleepComponents = calendar.dateComponents([.hour, .minute], from: sleepTime)
                let wakeComponents = calendar.dateComponents([.hour, .minute], from: Date.now)
                
                let sleepMinutes = (sleepComponents.hour ?? 0) * 60 + (sleepComponents.minute ?? 0)
                var wakeMinutes = (wakeComponents.hour ?? 0) * 60 + (wakeComponents.minute ?? 0)
                
                if wakeMinutes <= sleepMinutes {
                    wakeMinutes += 24 * 60
                }
                
                let totalHours = Double((wakeMinutes - sleepMinutes) / 60)
                
                let entry = sleepDurationStruct(date: Date.now, duration: totalHours)
                context.insert(entry)
                do {
                    print(entry)
                    try context.save()
                    print("Saved duration:", totalHours)
                } catch {
                    print("Failed to save duration:", error)
                }
                UIAccessibility.requestGuidedAccessSession(enabled: false) { success in
                    if success {
                        print("Guided Access session ended successfully")
                        isGuidedAccessActive = false
                    } else {
                        print("Failed to end Guided Access session.")
                    }
                }
                withAnimation {
                    showSleepView = false
                }
            }label: {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.red)
                    .frame(width: 200, height: 70)
                    .overlay(
                        Text("Wake Up Now")
                            .foregroundStyle(.white)
                    )
            }
        }
        .onAppear {
            UIAccessibility.requestGuidedAccessSession(enabled: true) { success in
                if success {
                    print("Guided Access session started successfully")
                    isGuidedAccessActive = true
                } else {
                    print("Failed to start Guided Access session. Check MDM configuration and device supervision.")
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SleepView(showSleepView: .constant(false), sleepTime: .constant(Date.now))
}
