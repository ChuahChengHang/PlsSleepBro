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
    @State private var guidedAccessModel = guidedAccessEnabled()
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
                .frame(height: 40)
            
            Text("Sleep Time")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.red)
            
            Button {
                handleWakeUp()
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
            
            HStack(spacing: 8) {
                Circle()
                    .fill(guidedAccessModel.enabled ? .green : .red)
                    .frame(width: 12, height: 12)
                
                Text("Guided Access: \(guidedAccessModel.enabled ? "On" : "Off")")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
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
    
    private func handleWakeUp() {
        let calendar = Calendar.current
        
        let sleepC = calendar.dateComponents([.hour, .minute], from: sleepTime)
        let wakeC = calendar.dateComponents([.hour, .minute], from: Date.now)
        
        let sleepMinutes = (sleepC.hour ?? 0) * 60 + (sleepC.minute ?? 0)
        var wakeMinutes = (wakeC.hour ?? 0) * 60 + (wakeC.minute ?? 0)
        
        if wakeMinutes <= sleepMinutes { wakeMinutes += 24 * 60 }
        
        let minutesSlept = wakeMinutes - sleepMinutes
        let hours = Double(minutesSlept) / 60.0
        
        let entry = sleepDurationStruct(date: .now, duration: hours)
        context.insert(entry)
        
        do { try context.save() } catch { print(error) }
        
        withAnimation { showSleepView = false }
    }
}


#Preview {
    SleepView(showSleepView: .constant(false), sleepTime: .constant(Date.now))
}

@Observable
class guidedAccessEnabled {
    var enabled: Bool = UIAccessibility.isGuidedAccessEnabled
}
