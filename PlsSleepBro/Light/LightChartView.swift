//
//  LightChartView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 19/11/25.
//

import SwiftUI
import SwiftData
import Charts

struct LightChartView: View {
    @Query private var lightData: [lightStruct]
    @Binding var date: Date
    @Binding var offSet: Int
    @State private var startHour: Int = 0
    var endHour: Int { startHour + 24 }
    let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.1), Color.green.opacity(0)]), startPoint: .top, endPoint: .bottom)
    @Binding var suggestions: [String]
    @Binding var selectedDateDataEmpty: Bool
    @State private var dayEntries: [lightStruct] = []
    @State private var hourlyData: [(time: Date, value: Double)] = []
    @State private var averageLight: Double = 0.0
    //    @State private var dragAmount: CGSize = .zero
    var body: some View {
        VStack {
            if !lightData.isEmpty {
                if dayEntries.isEmpty {
                    ContentUnavailableView {
                        Label("No Data", systemImage: "xmark.circle")
                    } description: {
                        Text("Graph of recent light intensity will appear here.")
                    }
                    .onAppear {
                        selectedDateDataEmpty = true
                    }
                } else {
                    Chart(hourlyData, id: \.time) { entry in
                        LineMark(
                            x: .value("Hour", entry.time),
                            y: .value("Light", entry.value)
                        )
                        PointMark(
                            x: .value("Hour", entry.time),
                            y: .value("Light", entry.value)
                        )
                        RuleMark(y: .value("Average", averageLight))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            .foregroundStyle(.yellow)
                            .annotation(position: .bottom) {
                                Text("Avg").foregroundStyle(.yellow)
                            }
                        
                        RectangleMark(yStart: .value("Recommended", 0), yEnd: .value("Recommended", 30))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            .foregroundStyle(linearGradient)
                            .annotation(position: .top) {
                                Text("Recommended").foregroundStyle(.green)
                            }
                    }
                    .chartPlotStyle { area in
                        area
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                    }
                    .chartScrollableAxes(.horizontal)
                    .chartXAxis {
                        AxisMarks(preset: .aligned, values: hourlyData.map { $0.time }) { value in
                            if let time = value.as(Date.self) {
                                AxisValueLabel(time.formatted(
                                    .dateTime
                                        .locale(.init(identifier: "en_UK"))
                                        .hour(.twoDigits(amPM: .omitted))
                                ))
                            }
                        }
                    }
                    .padding(.bottom, 40)
                    .aspectRatio(1, contentMode: .fit)
                    .padding()
                    .overlay(
                        VStack(alignment: .leading, spacing: 4) {
                            Text("X-Axis: Time(Hours)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Y-Axis: Average Light Per Hour(Lux)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                            .padding(), alignment: .bottom
                    )
                    //            .gesture(
                    //                DragGesture()
                    //                    .onEnded { gesture in
                    //                        if gesture.translation.width < -50 {
                    //                            withAnimation {
                    //                                halfDayStartHour = halfDayStartHour == 0 ? 12 : 0
                    //                            }
                    //                        }
                    //                        if gesture.translation.width > 50 {
                    //                            withAnimation {
                    //                                halfDayStartHour = halfDayStartHour == 12 ? 0 : 12
                    //                            }
                    //                        }
                    //                    }
                    //            )
                    //            .sensoryFeedback(.increase, trigger: halfDayStartHour)
                    //            .sensoryFeedback(.decrease, trigger: halfDayStartHour)
                    .onAppear {
                        computeData()
                        updateSuggestions()
                        print("Avg Light: ", averageLight)
                        print("Max Light: ", hourlyData.map({ $0.value }).max() ?? 0)
                    }
                    .onChange(of: date) {
                        computeData()
                        updateSuggestions()
                    }
                }
            }else {
                ContentUnavailableView {
                    Label("No Data", systemImage: "xmark.circle")
                } description: {
                    Text("Graph of recent light intensity will appear here.")
                }
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: date) {
            selectedDateDataEmpty = dayEntries.isEmpty
        }
        .onChange(of: lightData) {
            computeData()
            selectedDateDataEmpty = dayEntries.isEmpty
            updateSuggestions()
        }
    }
    //    private func updateSelectedDateDataEmpty() {
    //        let calendar = Calendar.current
    //        let selectedDate = calendar.date(byAdding: .day, value: offSet, to: date)!
    //
    //        let dayEntries = lightData.filter {
    //            calendar.isDate($0.date, inSameDayAs: selectedDate)
    //        }
    //
    //        selectedDateDataEmpty = dayEntries.isEmpty
    //    }
    private func updateSuggestions() {
        suggestions.removeAll()
        if averageLight == 0 {
            suggestions.append("No light data detected for this period.")
            return
        }
        
        if averageLight > 0 && averageLight <= 10{
            suggestions.append("Your room was extremely dark, which is ideal for sleep. Keep up the good sleep environment!")
        }
        
        if averageLight > 10 && averageLight < 30 {
            suggestions.append("Your sleep environment had moderately low light levels, which is generally good for melatonin production and sleep.")
        }
        
        if averageLight > 29 && averageLight < 59 {
            suggestions.append("Your sleep environment had moderate light levels. You should be mindful of strong lighting.")
        }
        
        if averageLight > 58 {
            suggestions.append("Your environment was very bright. Consider reducing strong lighting to avoid disrupting sleep.")
        }
        
        if let maxLight = hourlyData.map({ $0.value }).max(), maxLight > 50 {
            suggestions.append("There were moments of bright light. Try keeping your sleep environment dim and consistent.")
        }
        
        if averageLight > 10 && averageLight <= 40 && (hourlyData.map({ $0.value }).max() ?? 0) <= 50 {
            suggestions.append("Your light exposure is within a reasonable range for sleep. Maintain a consistent dim environment for better rest.")
        }
        
    }
    private func computeData() {
        let calendar = Calendar.current
        let selectedDate = calendar.date(byAdding: .day, value: offSet, to: date)!
        
        dayEntries = lightData.filter {
            calendar.isDate($0.date, inSameDayAs: selectedDate)
        }
        
        hourlyData = (startHour..<endHour).map { hour -> (time: Date, value: Double) in
            let hourStart = calendar.date(bySettingHour: hour % 24, minute: 0, second: 0, of: selectedDate)!
            let avgValue = dayEntries
                .filter { calendar.component(.hour, from: $0.date) == hour % 24 }
                .map { $0.light }
                .average ?? 0.0
            return (hourStart, avgValue)
        }
        let nonZeroValues = hourlyData.map { $0.value }.filter { $0 > 1.0 }
        
        averageLight = nonZeroValues.isEmpty
        ? 0
        : nonZeroValues.reduce(0, +) / Double(nonZeroValues.count)
    }
}

#Preview {
    LightChartView(date: .constant(Date.now), offSet: .constant(0), suggestions: .constant([]), selectedDateDataEmpty: .constant(false))
}
