//
//  ContentView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 15/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var durationData: [Int]?
    @State private var lightData: [Double]?
    @State private var noiseData: [Double]?
    @State private var activateSleepAlarmSheet: Bool = false
    @State private var tip: String = ""
    @State private var setTimeToWakeUp = Date()
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
                RoundedRectangle(cornerRadius: 14)
                    .frame(width: 360, height: 200)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Home")
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
