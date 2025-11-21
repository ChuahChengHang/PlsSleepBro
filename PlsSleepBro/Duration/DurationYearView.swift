//
//  DurationYearView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 18/11/25.
//

import SwiftUI
import SwiftData
import Charts

struct DurationYearView: View {
    @Query private var durationData: [sleepDurationStruct]
    @Binding var average: Double
    @Binding var offset: Int
    @GestureState private var dragOffset: CGFloat = 0
    var body: some View {
        VStack {
            if !durationData.isEmpty {

                let calendar = Calendar.current
                let today = Date()
                let startOfCurrentMonth = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: today)
                )!
                let startOfSelectedYear = calendar.date(
                    byAdding: .year,
                    value: offset,
                    to: startOfCurrentMonth
                )!
                let monthStartDates = (0..<12).compactMap { index in
                    calendar.date(byAdding: .month, value: index, to: startOfSelectedYear)
                }
                let monthlyData: [(monthStart: Date, totalHours: Double)] = monthStartDates.map { monthStart in
                    let hours = durationData
                        .filter { calendar.isDate($0.date, equalTo: monthStart, toGranularity: .month) }
                        .map { $0.duration }
                        .reduce(0, +)

                    return (monthStart, hours)
                }

                let averageDuration = monthlyData.map { $0.totalHours }.reduce(0, +) / 12

                let firstMonth = monthlyData.first!.monthStart
                let lastMonth = monthlyData.last!.monthStart

                Chart(monthlyData, id: \.monthStart) { monthStart, totalHours in
                    LineMark(
                        x: .value("Month", monthStart),
                        y: .value("Hours", totalHours)
                    )
                    PointMark(
                        x: .value("Month", monthStart),
                        y: .value("Hours", totalHours)
                    )

                    RuleMark(y: .value("Average", averageDuration))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(.yellow)
                        .annotation(position: .bottom) {
                            Text("avg").foregroundStyle(.yellow)
                        }

                    RuleMark(y: .value("Recommended", 280))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(.green)
                        .annotation(position: .bottom) {
                            Text("recommended").foregroundStyle(.green)
                        }
                }
                .chartXScale(domain: firstMonth...lastMonth)
                .chartXAxis {
                    AxisMarks(preset: .aligned, values: monthlyData.map { $0.monthStart }) { value in
                        if let date = value.as(Date.self) {
                            let label = date.formatted(.dateTime.month(.abbreviated))
                            AxisGridLine()
                            AxisValueLabel(label)
                        }
                    }
                }
                .padding()
                .animation(.easeInOut, value: offset)
                .onAppear { average = averageDuration }
                .onChange(of: startOfSelectedYear) {
                    average = averageDuration
                }
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 80

                            if value.translation.width < -threshold {
                                offset += 1
                            } else if value.translation.width > threshold {
                                offset -= 1
                            }
                        }
                )
                .sensoryFeedback(.increase, trigger: offset)
                .sensoryFeedback(.decrease, trigger: offset)
            }
        }
        .preferredColorScheme(.dark)
    }
}


#Preview {
    DurationYearView(average: .constant(0.0), offset: .constant(0))
}
