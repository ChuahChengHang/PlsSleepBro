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
                    DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .offset(x: -140)
                        .sensoryFeedback(.impact(weight: .light), trigger: selectedDate)
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.quaternary)
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
                    Spacer()
                }
            }
            .preferredColorScheme(.dark)
            .navigationTitle("Light")
        }
    }
}

#Preview {
    LightView()
}
