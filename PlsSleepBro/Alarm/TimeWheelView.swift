//
//  TimeWheelView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 16/11/25.
//

import SwiftUI


struct TimeWheelView: View {
    @State private var angle: Double = -90
    @State private var selectedHour: Int = 6
    @State private var selectedMinute: Int = 0
    @Binding var setTimeToWakeUp: Date
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.4), lineWidth: 18)

            ForEach(0..<24) { i in
                Rectangle()
                    .fill(i % 6 == 0 ? .gray : .gray.opacity(0.5))
                    .frame(width: 2, height: i % 6 == 0 ? 14 : 7)
                    .offset(y: -130)
                    .rotationEffect(.degrees(Double(i) / 24 * 360))
            }

            Rectangle()
                .fill(Color.red)
                .frame(width: 4, height: 35)
                .offset(y: -123)
                .rotationEffect(.degrees(angle))

            Circle()
                .fill(Color.clear)
                .contentShape(Circle())
                .gesture(
                    DragGesture().onChanged { value in
                        updateAngle(from: value)
                        updateTimeFromAngle()
                    }
                )

            VStack {
                Text("Selected Time To Wake Up:")
                    .font(.headline)
                Text(timeString)
                    .font(.title2)
            }
        }
        .frame(width: 300, height: 300)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"

        var comps = DateComponents()
        comps.hour = selectedHour
        comps.minute = selectedMinute
        
        let date = Calendar.current.date(from: comps) ?? Date()
        setTimeToWakeUp = date
        return formatter.string(from: date)
    }

    private func updateAngle(from value: DragGesture.Value) {
        let dx = value.location.x - 150
        let dy = value.location.y - 150
        let newAngle = atan2(dy, dx) * 180 / .pi + 90
        angle = newAngle
    }

    private func updateTimeFromAngle() {
        let adjusted = (angle < 0 ? angle + 360 : angle)
        let totalMinutes = adjusted / 360 * 1440

        selectedHour = Int(totalMinutes) / 60
        selectedMinute = Int(totalMinutes) % 60
    }
}

#Preview {
    TimeWheelView(setTimeToWakeUp: .constant(Date()))
}
