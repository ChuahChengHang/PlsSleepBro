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
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.quaternary)
                        .frame(width: 380, height: 400)
                        .padding(.top, 10)
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
//                        RoundedRectangle(cornerRadius: 18)
//                            .fill(.quaternary)
//                            .frame(width: 380, height: 100)
//                            .overlay(
                                ContentUnavailableView {
                                    Text("No Data")
                                        .bold()
                                } description: {
                                    Text("Suggestions will appear here.")
                                }
                                    .padding(.top, 10)
//                            )
//                            .padding(.horizontal)
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DatePicker("",selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    .sensoryFeedback(.impact(weight: .light), trigger: selectedDate)
                    .labelsHidden()
                }
            }
        }
    }
}

#Preview {
    NoiseView()
}
