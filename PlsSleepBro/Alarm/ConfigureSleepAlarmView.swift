//
//  ConfigureSleepAlarmView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 15/11/25.
//

import SwiftUI
import AlarmKit

nonisolated struct TimerData: AlarmMetadata, Codable, Sendable {}

struct ConfigureSleepAlarmView: View {
    private let manager = AlarmManager.shared
    @Binding var setTimeToWakeUp: Date
    @State private var activateErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var selectedSnoozeMinute: Int = 1
    @State private var selectedSnoozeSecond: Int = 0
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TimeWheelView(setTimeToWakeUp: $setTimeToWakeUp)
                    HStack {
                        Text("Snooze Duration")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        Spacer()
                    }
                    HStack {
                        Picker("Snooze Minute", selection: $selectedSnoozeMinute) {
                            ForEach(0..<11) { number in
                                Text("\(number) **min**")
                            }
                        }
                        .pickerStyle(.wheel)
                        Picker("Snooze Second", selection: $selectedSnoozeSecond) {
                            ForEach(0..<60) { number in
                                Text("\(number) **sec**")
                            }
                        }
                        .pickerStyle(.wheel)
                    }
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
                    let permissionAllowed = await checkForAuthorisation()
                    if permissionAllowed {
                        await scheduleTimer()
                        dismiss()
                    }else {
                        activateErrorAlert = true
                        errorMessage = "Please allow the app to use AlarmKit in your settings."
                    }
                }
            }label: {
                RoundedRectangle(cornerRadius: 14)
                    .fill(selectedSnoozeMinute == 0 && selectedSnoozeSecond == 0 ? .gray : .orange)
                    .frame(width: 370, height: 70)
                    .overlay(
                        Text("Sleep Now")
                            .foregroundStyle(.white)
                    )
            }
            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
            .disabled(selectedSnoozeMinute == 0 && selectedSnoozeSecond == 0 ? true : false)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    }label: {
                        Text("Cancel")
                    }
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
        let wakeUpTime = Calendar.current.dateComponents([.hour, .minute], from: setTimeToWakeUp)
        var triggerDate = Calendar.current.date(
            bySettingHour: wakeUpTime.hour!, minute: wakeUpTime.minute!, second: 0, of: Date()
        )
        if triggerDate! <= Date() {
            triggerDate = Calendar.current.date(byAdding: .day, value: 1, to: triggerDate!)
        }
        //        let snoozeTime = TimeInterval(selectedSnoozeMinute * 60 + selectedSnoozeSecond)
        let schedule = Alarm.Schedule.fixed(triggerDate!)
        let alert = AlarmPresentation.Alert(
            title: "Time to wake up!",
            stopButton: AlarmButton(text: "Stop", textColor: .white, systemImageName: "checkmark.app.fill"),
            secondaryButton: AlarmButton(
                text: "Snooze",
                textColor: .blue,
                systemImageName: "moon.zzz.fill"
            ),
        )
        let attributes = AlarmAttributes<TimerData>(
            presentation: AlarmPresentation(alert: alert), tintColor: .yellow
        )
        do {
            let id = UUID()
            UserDefaults.standard.set(id, forKey: "sleepAlarmID")
            let alarm = try await manager.schedule(
                id: id,
                configuration: .alarm(
                    schedule: schedule,
                    attributes: attributes
                )
            )
        }catch {
            print("Error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            activateErrorAlert = true
        }
    }
}

#Preview {
    ConfigureSleepAlarmView(setTimeToWakeUp: .constant(Date()))
}
