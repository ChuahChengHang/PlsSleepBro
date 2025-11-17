//
//  DurationView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 17/11/25.
//

import SwiftUI
import Charts

struct DurationView: View {
    @Binding var durationData: [Int]?
    @State private var selectedDate = Date.now
    var body: some View {
        VStack {
            HStack {
                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .offset(x: -140)
            }
            Spacer()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    DurationView(durationData: .constant([0]))
}
