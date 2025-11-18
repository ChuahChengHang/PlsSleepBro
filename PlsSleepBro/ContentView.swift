//
//  ContentView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 15/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var durationData: [sleepDurationStruct]
    @State private var lightData: [Double]?
    @State private var noiseData: [Double]?
    @State private var activateSleepAlarmSheet: Bool = false
    @State private var tip: String = ""
    @State private var setTimeToWakeUp = Date()
    @State private var hasSeenSheet = false
    @State private var showSheet = false
    @State private var totalNoiseData: Double = 0.0
    @State private var progress: CGFloat = 0.0
    @State private var durationSlept: String = "0h"
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
                if !durationData.isEmpty && lightData != nil && noiseData != nil {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(.secondary)
                        .frame(width: 380, height: 120)
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
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 380, height: 200)
                        .overlay(
                            VStack {
                                HStack {
                                    Text("Alarm")
                                        .foregroundStyle(.white)
                                        .font(.title)
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
                    DurationView()
                }label: {
                    RoundedRectangle(cornerRadius: 14)
                        .frame(width: 380, height: 200)
                        .overlay(
                            VStack {
                                HStack {
                                    VStack{
                                        Text("Duration")
                                            .foregroundStyle(.white)
                                            .font(.title)
                                            .bold()
                                        Text("TODAY")
                                            .font(.subheadline)
                                            .foregroundStyle(.gray)
                                            .bold()
                                        Spacer()
                                        Text(durationSlept)
                                            .foregroundStyle(.white)
                                            .font(.title2)
                                        Spacer()
                                    }
                                    Spacer()
                                    ZStack {
                                        ActivityRingView(progress: $progress)
                                        Text(progress * 100.0 == 0 ? "0%" : "\(Int(progress * 100.0))%")
                                            .foregroundStyle(.white)
                                            .font(.largeTitle)
                                            .bold()
                                    }
                                }
                                Spacer()
                            }
                                .padding()
                        )
                }
                .foregroundStyle(Color.gray.opacity(0.2))
                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                NavigationLink {
                    
                }label: {
                    RoundedRectangle(cornerRadius: 14)
                        .frame(width: 380, height: 200)
                        .overlay(
                            VStack {
                                HStack {
                                    Text("Light")
                                        .foregroundStyle(.white)
                                        .font(.title)
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                            }
                                .padding()
                        )
                }
                    .foregroundStyle(Color.gray.opacity(0.2))
                    .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                NavigationLink {
                    NoiseView()
                }label: {
                    RoundedRectangle(cornerRadius: 14)
                        .frame(width: 380, height: 200)
                        .overlay(
                            VStack {
                                HStack {
                                    Text("Noise")
                                        .foregroundStyle(.white)
                                        .font(.title)
                                        .bold()
                                    Spacer()
                                }
                                .padding()
                                VStack {
                                    HStack {
                                        Image(systemName: "speaker.fill")
                                            .resizable()
                                            .frame(width: 34, height: 40)
                                            .foregroundStyle(.white)
                                        ForEach(0..<10) { index in
                                            Rectangle()
                                                .frame(width: 14, height: 40)
                                                .foregroundStyle(index < filledBlocks ? Color.white : Color.clear)
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
                .foregroundStyle(Color.gray.opacity(0.2))
                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
            }
            .navigationTitle("Home")
            .preferredColorScheme(.dark)
            .scrollIndicators(.hidden)
        }
        .onAppear {
            if hasSeenSheet {
                return
            }else {
                showSheet = true
            }
            let now = Date()
            if !durationData.isEmpty {
                let data = durationData
                let index = data.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: now) })
                let duration = data[index!].duration
                let totalMinutes = Int(duration * 60)
                
                if totalMinutes < 60 {
                    durationSlept = "\(totalMinutes)min"
                } else {
                    let hours = totalMinutes / 60
                    let minutes = totalMinutes % 60
                    
                    if minutes == 0 {
                        durationSlept = "\(hours)h"
                    } else {
                        durationSlept = "\(hours)h \(minutes)min"
                    }
                }
                progress = CGFloat(duration) / 10
            } else {
                progress = 0.0
            }
        }
//                .onAppear {
//                    var sampleData: [sleepDurationStruct] {
//                        let calendar = Calendar.current
//                        return (0..<365).map { offset in
//                            let date = calendar.date(byAdding: .day, value: -offset, to: .now)!
//                            let duration = Double.random(in: 6.0...10.9)
//                            return sleepDurationStruct(date: date, duration: Double(duration))
//                        }
//                    }
//                    for i in sampleData {
//                        context.insert(i)
//                    }
//                    do {
//                        try context.save()
//                        print("successfully injected data")
//                    }catch {
//                        print("error: \(error.localizedDescription)")
//                    }
//                }
        .sheet(isPresented: $showSheet) {
            GuidedAccessSheet(hasSeenSheet: $hasSeenSheet)
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    ContentView()
}

