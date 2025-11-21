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
    @State private var halfDayStartHour: Int = 0
    @State private var dragAmount: CGSize = .zero
    var halfDayEndHour: Int { halfDayStartHour + 12 }
    let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.1), Color.green.opacity(0)]), startPoint: .top, endPoint: .bottom)
    @Binding var suggestions: [String]
    var body: some View {
        VStack {
            let calendar = Calendar.current
            let selectedDate = calendar.date(byAdding: .day, value: offSet, to: date)!
            
            let dayEntries = lightData.filter {
                calendar.isDate($0.date, inSameDayAs: selectedDate)
            }
            
            let hourlyData = (halfDayStartHour..<halfDayEndHour).map { hour -> (time: Date, value: Double) in
                let hourStart = calendar.date(bySettingHour: hour % 24, minute: 0, second: 0, of: selectedDate)!
                let avgValue = dayEntries
                    .filter { calendar.component(.hour, from: $0.date) == hour % 24 }
                    .map { $0.light }
                    .average ?? 0.0
                return (hourStart, avgValue)
            }
            let averageLight = hourlyData.isEmpty
            ? 0
            : hourlyData.map { $0.value }.reduce(0, +) / Double(hourlyData.count)
            
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
                        Text("avg").foregroundStyle(.yellow)
                    }
                
                RectangleMark(yStart: .value("Recommended", 0), yEnd: .value("Recommended", 30))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .foregroundStyle(linearGradient)
                    .annotation(position: .top) {
                        Text("recommended").foregroundStyle(.green)
                    }
            }
            .chartXAxis {
                AxisMarks(preset: .aligned, values: hourlyData.map { $0.time }) { value in
                    if let time = value.as(Date.self) {
                        AxisValueLabel(time.formatted(.dateTime.hour()))
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .padding()
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width < -50 {
                            withAnimation {
                                halfDayStartHour = halfDayStartHour == 0 ? 12 : 0
                            }
                        }
                        if gesture.translation.width > 50 {
                            withAnimation {
                                halfDayStartHour = halfDayStartHour == 12 ? 0 : 12
                            }
                        }
                    }
            )
            .sensoryFeedback(.increase, trigger: halfDayStartHour)
            .sensoryFeedback(.decrease, trigger: halfDayStartHour)
            .onAppear {
                    if averageLight == 0 {
                        suggestions.append("No light data detected for this period.")
                        return
                    }

                    if averageLight <= 10 {
                        suggestions.append("Your room was extremely dark, which is ideal for sleep. Keep up the good sleep environment!")
                    }

                    if averageLight > 10 && averageLight < 30 {
                        suggestions.append("Your sleep environment had moderately low light levels, which is generally good for melatonin production and sleep.")
                    }

                    if averageLight > 80 {
                        suggestions.append("Your environment was very bright. Consider reducing strong lighting to avoid disrupting sleep.")
                    }

                    if let maxLight = hourlyData.map({ $0.value }).max(), maxLight > 60 {
                        suggestions.append("There were moments of bright light. Try keeping your sleep environment dim and consistent.")
                    }

                    if averageLight > 10 && averageLight <= 80 && (hourlyData.map({ $0.value }).max() ?? 0) <= 60 {
                        suggestions.append("Your light exposure is within a reasonable range for sleep. Maintain a consistent dim environment for better rest.")
                    }
            }
            .onChange(of: date) {
                    suggestions.removeAll()

                    if averageLight == 0 {
                        suggestions.append("No light data detected for this period.")
                        return
                    }

                    if averageLight <= 10 {
                        suggestions.append("Your room was extremely dark, which is ideal for sleep. Keep up the good sleep environment!")
                    }

                    if averageLight > 10 && averageLight < 30 {
                        suggestions.append("Your sleep environment had moderately low light levels, which is generally good for melatonin production and sleep.")
                    }

                    if averageLight > 80 {
                        suggestions.append("Your environment was very bright. Consider reducing strong lighting to avoid disrupting sleep.")
                    }

                    if let maxLight = hourlyData.map({ $0.value }).max(), maxLight > 60 {
                        suggestions.append("There were moments of bright light. Try keeping your sleep environment dim and consistent.")
                    }

                    if averageLight > 10 && averageLight <= 80 && (hourlyData.map({ $0.value }).max() ?? 0) <= 60 {
                        suggestions.append("Your light exposure is within a reasonable range for sleep. Maintain a consistent dim environment for better rest.")
                    }

            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    LightChartView(date: .constant(Date.now), offSet: .constant(0), suggestions: .constant([]))
}
