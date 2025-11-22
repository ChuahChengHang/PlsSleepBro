//
//  NoiseChatView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 19/11/25.
//

import SwiftUI
import SwiftData
import Charts

struct NoiseChartView: View {
    @Query private var noiseData: [noiseStruct]
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
            
            let dayEntries = noiseData.filter {
                calendar.isDate($0.date, inSameDayAs: selectedDate)
            }
            
            let hourlyData = (halfDayStartHour..<halfDayEndHour).map { hour -> (time: Date, value: Double) in
                let hourStart = calendar.date(bySettingHour: hour % 24, minute: 0, second: 0, of: selectedDate)!
                let avgValue = dayEntries
                    .filter { calendar.component(.hour, from: $0.date) == hour % 24 }
                    .map { $0.noise }
                    .average ?? 0.0
                return (hourStart, avgValue)
            }
            var averageNoise: Double {
                let calendar = Calendar.current
                let selectedDate = calendar.date(byAdding: .day, value: offSet, to: date)!
                
                let dayEntries = noiseData.filter {
                    calendar.isDate($0.date, inSameDayAs: selectedDate)
                }
                
                let values = dayEntries.map { $0.noise }
                return values.average ?? 0.0
            }
            
            
            Chart(hourlyData, id: \.time) { entry in
                LineMark(
                    x: .value("Hour", entry.time),
                    y: .value("Noise", entry.value)
                )
                PointMark(
                    x: .value("Hour", entry.time),
                    y: .value("Noise", entry.value)
                )
                RuleMark(y: .value("Average", averageNoise))
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
                if suggestions.isEmpty {
                    if averageNoise == 0 {
                        suggestions.append("No noise data recorded for this period.")
                    } else if averageNoise > 60 {
                        suggestions.append("Your environment was very noisy. Consider using earplugs, closing windows, or reducing nearby activity.")
                    } else if averageNoise > 30 {
                        suggestions.append("Your noise levels were slightly high. Try reducing background noise or enabling white noise to mask sudden sounds.")
                    } else if let maxNoise = hourlyData.map({ $0.value }).max(), maxNoise > 70 {
                        suggestions.append("You experienced loud noise spikes. These may disturb sleep—try identifying and removing sudden noise sources.")
                    } else if averageNoise < 10 {
                        suggestions.append("Excellent sleep environment! Very quiet and ideal for restful sleep.")
                    } else {
                        suggestions.append("Your noise levels are within a healthy range. Keep maintaining a quiet sleep environment.")
                    }
                }
            }
            .onChange(of: date) {
                suggestions.removeAll()
                if suggestions.isEmpty {
                    if averageNoise == 0 {
                        suggestions.append("No noise data recorded for this period.")
                    }
                    if averageNoise > 60 {
                        suggestions.append("Your environment was very noisy. Consider using earplugs, closing windows, or reducing nearby activity.")
                    }
                    if averageNoise > 30 {
                        suggestions.append("Your noise levels were slightly high. Try reducing background noise or enabling white noise to mask sudden sounds.")
                    }
                    if let maxNoise = hourlyData.map({ $0.value }).max(), maxNoise > 70 {
                        suggestions.append("You experienced loud noise spikes. These may disturb sleep—try identifying and removing sudden noise sources.")
                    }
                    if averageNoise < 10 {
                        suggestions.append("Excellent sleep environment! Very quiet and ideal for restful sleep.")
                    } else {
                        suggestions.append("Your noise levels are within a healthy range. Keep maintaining a quiet sleep environment.")
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}


extension Array where Element == Double {
    var average: Double {
        isEmpty ? 0 : reduce(0, +) / Double(count)
    }
}


#Preview {
    NoiseChartView(date: .constant(Date.now), offSet: .constant(0), suggestions: .constant([]))
}
