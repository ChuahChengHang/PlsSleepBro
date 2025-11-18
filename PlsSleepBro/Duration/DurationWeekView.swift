//
//  DurationWeekView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 17/11/25.
//

import SwiftUI
import Charts
import SwiftData

struct DurationWeekView: View {
    @Query private var durationData: [sleepDurationStruct]
    @Binding var dailyAverage: Double
    @Binding var weekOffset: Int
    @State private var dragAmount: CGSize = .zero
    var body: some View {
        VStack {
            if !durationData.isEmpty {
                let calendar = Calendar.current
                let today = Date()
                let startOfCurrentWeek = calendar.date(
                    from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
                )!

                let startOfWeek = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfCurrentWeek)!

                let weekDates = (0..<7).compactMap { offset in
                    calendar.date(byAdding: .day, value: offset, to: startOfWeek)
                }

                let weekData = weekDates.map { date -> (date: Date, duration: Double) in
                    if let entry = durationData.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                        return (date, entry.duration)
                    } else {
                        return (date, 0)
                    }
                }

                let averageDuration = weekData.map { $0.duration }.reduce(0, +) / 7

                Chart(weekData, id: \.date) { value in
                    LineMark(
                        x: .value("Day", value.date),
                        y: .value("Hours", value.duration)
                    )
                    PointMark(
                        x: .value("Day", value.date),
                        y: .value("Hours", value.duration)
                    )

                    RuleMark(y: .value("Average", averageDuration))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(.yellow)
                        .annotation(position: .bottom) { Text("avg").foregroundColor(.yellow) }

                    RuleMark(y: .value("Recommended", 10))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(.green)
                        .annotation(position: .bottom) { Text("recommended").foregroundColor(.green) }
                }
                .chartXAxis {
                    AxisMarks(values: weekDates) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel(date.formatted(.dateTime.weekday(.abbreviated)))
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .padding()
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if gesture.translation.width < -50 {
                                withAnimation { weekOffset += 1 }
                            }
                            if gesture.translation.width > 50 {
                                withAnimation { weekOffset -= 1 }
                            }
                        }
                )
                .onAppear {
                    dailyAverage = averageDuration
                }
                .onChange(of: startOfWeek) {
                    dailyAverage = averageDuration
                }
            } else {
                Text("No data available")
            }
        }
        .preferredColorScheme(.dark)
    }
}


#Preview {
    DurationWeekView(dailyAverage: .constant(0.0), weekOffset: .constant(0))
}
