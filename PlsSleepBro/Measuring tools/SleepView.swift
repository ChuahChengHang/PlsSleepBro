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
    @Binding var showSleepView: Bool
    @Binding var sleepTime: Date
    @State private var showGuidedAccessSheet: Bool = false
    var body: some View {
        VStack {
            VisionView()
            MicrophoneView()
            Text("Sleep Time")
                .foregroundStyle(.red)
                .font(.largeTitle)
            Button {
                showGuidedAccessSheet = true
            }label: {
                Text("Guided Access")
                    .padding()
            }
            .sheet(isPresented: $showGuidedAccessSheet) {
                GuidedAccessView()
            Text("Please keep your phone's back camera facing up so we can track the amount of light around your area.")
            }
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
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SleepView(showSleepView: .constant(false), sleepTime: .constant(Date.now))
}
