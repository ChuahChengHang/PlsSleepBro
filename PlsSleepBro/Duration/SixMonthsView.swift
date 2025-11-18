//
//  SixMonthsView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 18/11/25.
//

import SwiftUI
import Charts
import SwiftData

struct SixMonthsView: View {
    @Query private var durationData: [sleepDurationStruct]
    @Binding var average: Double
    @Binding var offset: Int
    @GestureState private var dragOffset: CGFloat = 0
    var body: some View {
        VStack {
            if !durationData.isEmpty {
                let calendar = Calendar.current
                let today = Date()

                let startOfMonth = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: today)
                )!

                let startOfSelectedPeriod = calendar.date(
                    byAdding: .month,
                    value: offset * 6,
                    to: startOfMonth
                )!

                let monthStartDates = (0..<6).compactMap { index in
                    calendar.date(byAdding: .month, value: -index, to: startOfSelectedPeriod)
                }.sorted()

                let monthlyData = monthStartDates.map { monthStart in
                    let total = durationData
                        .filter { calendar.isDate($0.date, equalTo: monthStart, toGranularity: .month) }
                        .map { $0.duration }
                        .reduce(0, +)

                    return (monthStart: monthStart, totalHours: total)
                }

                let averageDuration = monthlyData.map { $0.totalHours }.reduce(0, +) / 6
                let firstMonth = monthStartDates.first!
                let lastMonth = monthStartDates.last!

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
                    AxisMarks(values: monthStartDates) { value in
                        if let date = value.as(Date.self) {
                            let label = date.formatted(.dateTime.month(.abbreviated))
                            AxisGridLine()
                            AxisValueLabel(label)
                        }
                    }
                }
                .padding()
                .animation(.easeInOut, value: offset)
                .onAppear {
                    average = averageDuration
                }
                .onChange(of: startOfSelectedPeriod) {
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

            } else {
                Text("No Data Available")
            }
        }
        .preferredColorScheme(.dark)
    }
}


#Preview {
    SixMonthsView(average: .constant(0.0), offset: .constant(0))
}
