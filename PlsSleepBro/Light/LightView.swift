//
//  LightView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 19/11/25.
//

import SwiftUI
import SwiftData

struct LightView: View {
    @Query private var lightData: [lightStruct]
    @State private var selectedDate: Date = Date.now
    @State private var offset: Int = 0
    @State private var suggestion: [String] = []
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.quaternary)
                        .padding(.top, 10)
                        .frame(width: 380, height: 400)
                        .overlay(
                            LightChartView(date: $selectedDate, offSet: $offset, suggestions: $suggestion)
                        )
                        .padding(.horizontal)
                }
                VStack {
                    HStack {
                        Text("Suggestions")
                            .font(.title)
                            .bold()
                            .padding(.horizontal, 5)
                        Spacer()
                    }
                    .padding()
                    if lightData.isEmpty {
                        ContentUnavailableView {
                            Text("No Data")
                                .bold()
                        } description: {
                            Text("Suggestions will appear here.")
                        }
                        .padding(.top, 10)
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
                    Spacer()
                }
            }
            .preferredColorScheme(.dark)
            .navigationTitle("Light")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
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
    LightView()
}
