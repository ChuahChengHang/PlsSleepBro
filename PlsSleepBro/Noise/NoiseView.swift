//
//  NoiseView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 18/11/25.
//

import SwiftUI
import SwiftData
import Charts

struct NoiseView: View {
    @Query private var noiseData: [noiseStruct]
    @State private var selectedDate: Date = Date.now
    @State private var offset: Int = 0
    @State private var suggestion: [String] = []
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .offset(x: -140)
                        .sensoryFeedback(.impact(weight: .light), trigger: selectedDate)
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.quaternary)
                        .frame(width: 380, height: 400)
                        .overlay(
                            NoiseChartView(date: $selectedDate, offSet: $offset, suggestions: $suggestion)
                        )
                        .padding(.horizontal)
                    HStack {
                        Text("Suggestions")
                            .font(.title)
                            .bold()
                            .padding(.horizontal, 5)
                        Spacer()
                    }
                    .padding()
                    if noiseData.isEmpty {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.quaternary)
                            .frame(width: 380, height: 400)
                            .overlay(
                                Text("No Available Data")
                                    .font(.largeTitle)
                                    .bold()
                            )
                            .padding(.horizontal)
                    }else {
                        LazyVStack(spacing: 0) {
                            ForEach(suggestion, id: \.self) { suggestion in
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(suggestion)
                                        .padding()
                                    Divider()
                                }
                                .background(Color(UIColor.systemBackground))
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .navigationTitle("Noise")
        }
    }
}

#Preview {
    NoiseView()
}
