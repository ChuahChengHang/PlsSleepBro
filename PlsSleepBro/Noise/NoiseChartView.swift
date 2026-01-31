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
    @Binding var suggestions: [String]
    @Binding var selectedDateDataEmpty: Bool

    @State private var dayEntries: [noiseStruct] = []
    @State private var hourlyData: [(time: Date, value: Double)] = []
    @State private var averageNoise: Double = 0

    let linearGradient = LinearGradient(
        gradient: Gradient(colors: [Color.green.opacity(0.1), Color.green.opacity(0)]),
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        VStack {
            if dayEntries.isEmpty {
                ContentUnavailableView {
                    Label("No Data", systemImage: "xmark.circle")
                } description: {
                    Text("Graph of recent noise will appear here.")
                }
            } else {
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

                    RectangleMark(
                        yStart: .value("Recommended", 0),
                        yEnd: .value("Recommended", 30)
                    )
                    .foregroundStyle(linearGradient)
                    .annotation(position: .top) {
                        Text("Recommended").foregroundStyle(.green)
                    }
                }
                .chartScrollableAxes(.horizontal)
                .chartXAxis {
                    AxisMarks(values: hourlyData.map { $0.time }) { value in
                        if let time = value.as(Date.self) {
                            AxisValueLabel(
                                time.formatted(
                                    .dateTime
                                        .locale(.init(identifier: "en_UK"))
                                        .hour(.twoDigits(amPM: .omitted))
                                )
                            )
                        }
                    }
                }
                .padding(.bottom, 40)
                .aspectRatio(1, contentMode: .fit)
                .padding()
                .overlay(
                    VStack(alignment: .leading, spacing: 4) {
                        Text("X-Axis: Time(Hour)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Y-Axis: Average Noise Per Hour")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(),
                    alignment: .bottom
                )
            }
        }
        .onAppear {
            recomputeData()
            updateSuggestions()
        }
        .onChange(of: date) {
            recomputeData()
            updateSuggestions()
        }
        .onChange(of: noiseData) {
            recomputeData()
            updateSuggestions()
        }
        .preferredColorScheme(.dark)
    }

    private func recomputeData() {
        let calendar = Calendar.current
        let selectedDate = calendar.date(byAdding: .day, value: offSet, to: date)!

        let entries = noiseData.filter {
            calendar.isDate($0.date, inSameDayAs: selectedDate)
        }

        dayEntries = entries
        averageNoise = entries.map(\.noise).average

        let grouped = Dictionary(grouping: entries) {
            calendar.component(.hour, from: $0.date)
        }

        hourlyData = (0..<24).map { hour in
            let hourStart = calendar.date(
                bySettingHour: hour,
                minute: 0,
                second: 0,
                of: selectedDate
            )!

            let values = grouped[hour]?.map(\.noise) ?? []
            return (hourStart, values.average)
        }

        selectedDateDataEmpty = entries.isEmpty
    }

    private func updateSuggestions() {
        suggestions.removeAll()

        if averageNoise == 0 {
            suggestions.append("No noise data recorded for this period.")
            return
        }

        if averageNoise > 50 {
            suggestions.append("Your environment was very noisy. Consider using earplugs, closing windows, or reducing nearby activity.")
        } else if averageNoise > 30 {
            suggestions.append("Your noise levels were slightly high. Try reducing background noise or enabling white noise to mask sudden sounds.")
        } else if let maxNoise = hourlyData.map(\.value).max(), maxNoise > 60 {
            suggestions.append("You experienced loud noise spikes. These may disturb sleep—try identifying and removing sudden noise sources.")
        } else if averageNoise < 10 {
            suggestions.append("Excellent sleep environment! Very quiet and ideal for restful sleep.")
        } else {
            suggestions.append("Your noise levels are within a healthy range. Keep maintaining a quiet sleep environment.")
        }
    }
}

extension Array where Element == Double {
    var average: Double {
        isEmpty ? 0 : reduce(0, +) / Double(count)
    }
}

#Preview {
    NoiseChartView(
        date: .constant(.now),
        offSet: .constant(0),
        suggestions: .constant([]),
        selectedDateDataEmpty: .constant(false)
    )
}
