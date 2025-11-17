//
//  DurationView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 17/11/25.
//

import SwiftUI
import Charts

enum timeScale: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case sixmonths = "6 Months"
    case year = "Year"
}

struct DurationView: View {
    @Binding var durationData: [sleepDurationStruct]?
    @State private var selectedTimeScale: timeScale = .week
    var body: some View {
        VStack {
            HStack {
                Picker("Time Schedule", selection: $selectedTimeScale) {
                    ForEach(timeScale.allCases, id: \.self) { value in
                        Text("\(value.rawValue)")
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }
            if durationData != nil {
                if selectedTimeScale == .week {
                    DurationWeekView(durationData: $durationData)
                }else if selectedTimeScale == .month {
                    DurationMonthView(durationData: $durationData)
                }
            }else {
                
            }
            Spacer()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    DurationView(durationData: .constant([sleepDurationStruct(date: Date.now, duration: 0)]))
}
