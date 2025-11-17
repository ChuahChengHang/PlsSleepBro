//
//  ContentView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 15/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var durationData: [sleepDurationStruct]? = [
        sleepDurationStruct(date: Calendar.current.date(byAdding: .day, value: -6, to: .now)!, duration: 9),
        sleepDurationStruct(date: Calendar.current.date(byAdding: .day, value: -5, to: .now)!, duration: 10),
        sleepDurationStruct(date: Calendar.current.date(byAdding: .day, value: -4, to: .now)!, duration: 10),
        sleepDurationStruct(date: Calendar.current.date(byAdding: .day, value: -3, to: .now)!, duration: 11),
        sleepDurationStruct(date: Calendar.current.date(byAdding: .day, value: -2, to: .now)!, duration: 11),
        sleepDurationStruct(date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!, duration: 12),
        sleepDurationStruct(date: Calendar.current.date(byAdding: .day, value: 0, to: .now)!, duration: 12)
    ]
    @State private var lightData: [Double]?
    @State private var noiseData: [Double]?
    @State private var activateSleepAlarmSheet: Bool = false
    @State private var tip: String = ""
    @State private var setTimeToWakeUp = Date()
    @State private var totalNoiseData: Double = 0.0
    private var clampedValue: Double {
        for i in noiseData ?? [0.0] {
            totalNoiseData += i
        }
        return min(max(totalNoiseData, 0), 100)
    }
    private var filledBlocks: Int {
        Int((clampedValue / 100.0 * 10.0).rounded())
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                if durationData != nil && lightData != nil && noiseData != nil {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(.secondary)
                        .frame(width: 370, height: 120)
                        .overlay(
                            VStack {
                                HStack {
                                    Text("Tip")
                                        .font(.title2)
                                        .bold()
                                    Spacer()
                                }
                                Divider()
                                    .overlay(.black)
                                Text(tip)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                            }
                                .padding()
                        )
                }
                Button {
                    activateSleepAlarmSheet = true
                }label: {
                    RoundedRectangle(cornerRadius: 14)
                        .frame(width: 360, height: 200)
                        .overlay(
                            VStack {
                                HStack {
                                    Text("Alarm")
                                        .foregroundStyle(.black)
                                        .font(.title2)
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                            }
                                .padding()
                        )
                }
                .sheet(isPresented: $activateSleepAlarmSheet) {
                    ConfigureSleepAlarmView(setTimeToWakeUp: $setTimeToWakeUp)
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                NavigationLink {
                    DurationView(durationData: $durationData)
                }label: {
                    RoundedRectangle(cornerRadius: 14)
                        .frame(width: 360, height: 200)
                        .overlay(
                            VStack {
                                HStack {
                                    Text("Duration")
                                        .foregroundStyle(.black)
                                        .font(.title2)
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                            }
                                .padding()
                        )
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                RoundedRectangle(cornerRadius: 14)
                    .frame(width: 360, height: 200)
                NavigationLink {
                    
                }label: {
                    RoundedRectangle(cornerRadius: 14)
                        .frame(width: 360, height: 200)
                        .overlay(
                            VStack {
                                HStack {
                                    Text("Noise")
                                        .foregroundStyle(.black)
                                        .font(.title2)
                                        .bold()
                                    Spacer()
                                }
                                .padding()
                                VStack {
                                    HStack {
                                        Image(systemName: "speaker.fill")
                                            .resizable()
                                            .frame(width: 34, height: 40)
                                            .foregroundStyle(.black)
                                        ForEach(0..<10) { index in
                                            Rectangle()
                                                .frame(width: 14, height: 40)
                                                .foregroundStyle(index < filledBlocks ? Color.primary : Color.clear)
                                                .overlay(
                                                    Rectangle()
                                                        .stroke(Color.primary, lineWidth: 2)
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                        }
                                    }
                                }
                                .padding()
                                Spacer()
                            }
                        )
                }
                .scrollIndicators(.hidden)
                .navigationTitle("Home")
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
}
