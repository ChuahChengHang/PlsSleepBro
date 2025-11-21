//
//  DurationMonthView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 17/11/25.
//

import SwiftUI
import Charts
import SwiftData

struct DurationMonthView: View {
    @Query private var durationData: [sleepDurationStruct]
    @Binding var weeklyAverage: Double
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
                
                let weekStartDates = (0..<4).compactMap { offset in
                    calendar.date(byAdding: .weekOfYear, value: -offset, to: startOfWeek)
                }.reversed()
                
                let weeklyData: [(weekStart: Date, totalHours: Double)] = weekStartDates.map { weekStart in
                    let totalHours = durationData
                        .filter { calendar.isDate($0.date, equalTo: weekStart, toGranularity: .weekOfYear) }
                        .map { $0.duration }
                        .reduce(0, +)
                    return (weekStart, totalHours)
                }
                
                let averageDuration = weeklyData.map { $0.totalHours }.reduce(0, +) / Double(weeklyData.count)
                
                Chart(weeklyData, id: \.weekStart) { value in
                    LineMark(
                        x: .value("Week", value.weekStart),
                        y: .value("Hours", value.totalHours)
                    )
                    PointMark(
                        x: .value("Week", value.weekStart),
                        y: .value("Hours", value.totalHours)
                    )
                    
                    RuleMark(y: .value("Average", averageDuration))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(.yellow)
                        .annotation(position: .bottom) { Text("avg").foregroundColor(.yellow) }
                    
                    RuleMark(y: .value("Recommended", 70))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(.green)
                        .annotation(position: .bottom) { Text("recommended").foregroundColor(.green) }
                }
                .chartXScale(domain: weeklyData.first!.weekStart...weeklyData.last!.weekStart)
                .chartXAxis {
                    AxisMarks(preset: .aligned, values: weeklyData.map { $0.weekStart }) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel(date.formatted(.dateTime.week()))
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
                .sensoryFeedback(.increase, trigger: weekOffset)
                .sensoryFeedback(.decrease, trigger: weekOffset)
                .onAppear { weeklyAverage = averageDuration }
                .onChange(of: startOfWeek) {
                    weeklyAverage = averageDuration
                }
            } else {
                Text("No data available")
            }
        }
        .preferredColorScheme(.dark)
    }
}


#Preview {
    DurationMonthView(weeklyAverage: .constant(0.0), weekOffset: .constant(0))
}
