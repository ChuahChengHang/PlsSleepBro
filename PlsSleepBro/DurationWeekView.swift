//
//  DurationWeekView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 17/11/25.
//

import SwiftUI
import Charts

struct DurationWeekView: View {
    @Binding var durationData: [sleepDurationStruct]?
    var body: some View {
        VStack {
            if let data = durationData {
                let sortedData = data.sorted { $0.date < $1.date }
                
                Chart(sortedData, id: \.self) { value in
                    LineMark(
                        x: .value("Day", value.date),
                        y: .value("Hours", value.duration)
                    )
                    PointMark(
                        x: .value("Day", value.date),
                        y: .value("Hours", value.duration)
                    )
                }
                .chartXAxis {
                    AxisMarks(values: sortedData.map { $0.date }) { value in
                        if let date = value.as(Date.self) {
                            let weekday = date.formatted(.dateTime.weekday(.abbreviated))
                            AxisGridLine()
                            AxisValueLabel(weekday)
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .padding()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    DurationWeekView(durationData: .constant([sleepDurationStruct(date: Date.now, duration: 0)]))
}
