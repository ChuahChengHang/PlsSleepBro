//
//  ConfigureSleepAlarmView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 15/11/25.
//

import SwiftUI
import AlarmKit
import UIKit

nonisolated struct TimerData: AlarmMetadata, Codable, Sendable, Hashable {}

struct ConfigureSleepAlarmView: View {
    private let manager = AlarmManager.shared
    @AppStorage("selectedHour") private var selectedHour: Int = 6
    @AppStorage("selectedMinute") private var selectedMinute: Int = 0
    @Binding var setTimeToWakeUp: Date
    @State private var activateErrorAlert: Bool = false
    @State private var errorMessage: String = ""
//    @State private var selectedSnoozeMinute: Int = 1
//    @State private var selectedSnoozeSecond: Int = 0
    @State private var success: Bool = false
    @State private var failed: Bool = false
    @Binding var sleepTime: Date
    @Binding var showSleepView: Bool
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TimeWheelView(selectedHour: $selectedHour, selectedMinute: $selectedMinute,setTimeToWakeUp: $setTimeToWakeUp)
                        .padding()
                    //                    HStack {
                    //                        Picker("Snooze Minute", selection: $selectedSnoozeMinute) {
                    //                            ForEach(0..<11) { number in
                    //                                Text("\(number) **min**")
                    //                            }
                    //                        }
                    //                        .pickerStyle(.wheel)
                    //                        Picker("Snooze Second", selection: $selectedSnoozeSecond) {
                    //                            ForEach(0..<60) { number in
                    //                                Text("\(number) **sec**")
                    //                            }
                    //                        }
                    //                        .pickerStyle(.wheel)
                    //                    }
                        .alert(isPresented: $activateErrorAlert) {
                            Alert(
                                title: Text("Error"),
                                message: Text("\(errorMessage)")
                            )
                        }
                }
            }
            Button {
                Task {
                    if await checkForAuthorisation() {
                        await scheduleTimer()
                        sleepTime = Date.now
                        success = true
                        dismiss()
                        withAnimation {
                            showSleepView = true
                        }
                    }else {
                        activateErrorAlert = true
                        failed = false
                        errorMessage = "Please allow the app to use AlarmKit in your settings."
                    }
                }
            }label: {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.red)
                    .frame(width: 370, height: 70)
                    .overlay(
                        Text("Sleep Now")
                            .foregroundStyle(.white)
                    )
            }
            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
            .sensoryFeedback(.success, trigger: success)
            .sensoryFeedback(.error, trigger: failed)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                        success = true
                    }label: {
                        Text("Cancel")
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: success)
                }
            }
            .onAppear {
                Task {
                    let allowed = await checkForAuthorisation()
                    print(allowed)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    private func checkForAuthorisation() async -> Bool {
        switch manager.authorizationState {
        case .notDetermined:
            do {
                let state = try await manager.requestAuthorization()
                return state == .authorized
            }catch {
                print("Error: \(error.localizedDescription)")
                return false
            }
        case .denied:
            return false
        case .authorized:
            return true
        @unknown default:
            return false
        }
    }
    private func scheduleTimer() async {
        let calendar = Calendar.current
        
        var triggerDate = calendar.date(bySettingHour: selectedHour, minute: selectedMinute, second: 0, of: Date())!
        
        if triggerDate <= Date() {
            triggerDate = calendar.date(byAdding: .day, value: 1, to: triggerDate)!
        }
        
        let now = Date()
        let interval = calendar.dateComponents([.hour, .minute], from: now, to: triggerDate)
        let time = Alarm.Schedule.Relative.Time(hour: interval.hour ?? 0, minute: interval.minute ?? 0)
        
        let schedule = Alarm.Schedule.relative(
            .init(
                time: time,
                repeats: .never
            )
        )
        
        let alert = AlarmPresentation.Alert(
            title: "Time to Wake Up!",
            stopButton: AlarmButton(
                text: "Stop",
                textColor: .white,
                systemImageName: "checkmark.circle.fill"
            ),
            secondaryButton: AlarmButton(
                text: "Snooze",
                textColor: .yellow,
                systemImageName: "zzz"
            )
        )
        
        let attributes = AlarmAttributes<TimerData>(
            presentation: AlarmPresentation(alert: alert),
            tintColor: .yellow
        )
        
        do {
            let id = UUID()
            let _ = try await AlarmManager.shared.schedule(
                id: id,
                configuration: .alarm(
                    schedule: schedule,
                    attributes: attributes
                )
            )
            print("Alarm scheduled with snooze.")
        } catch {
            print("Error: \(error)")
        }
    }
    
}

#Preview {
    ConfigureSleepAlarmView(setTimeToWakeUp: .constant(Date()), sleepTime: .constant(Date.now), showSleepView: .constant(false))
}
