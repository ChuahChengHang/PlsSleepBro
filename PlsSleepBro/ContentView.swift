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
    @Query private var lightData: [lightStruct]
    @Query private var durationData: [sleepDurationStruct]
    @Query private var noiseData: [noiseStruct]
    
    @State private var activateSleepAlarmSheet: Bool = false
    @AppStorage("wakeUpTime") private var setTimeToWakeUp = Date()
    @AppStorage("guidedAccessSheetSeen") private var hasSeenSheet = false
    @State private var showSheet = false
    @State private var totalNoiseData: Double = 0.0
    @State private var totalLightData: Double = 0.0
    @State private var progress: CGFloat = 0.0
    @State private var durationSlept: String = "0h"
    @State private var noiseFilledBlocks: Int = 0
    @State private var lightFilledBlocks: Int = 0
    @AppStorage("sleepTime") private var sleepTime: Date = Date.now
    @State private var sleeptip: String = ""
    @State private var lighttip: String = ""
    @State private var noisetip: String = ""
    @AppStorage("showSleepView") private var showSleepView: Bool = false
    
    var body: some View {
        if !showSleepView {
            NavigationStack {
                ScrollView {
                    if !durationData.isEmpty && !lightData.isEmpty && !noiseData.isEmpty {
                        if !sleeptip.isEmpty && !lighttip.isEmpty && !noisetip.isEmpty {
                            TipsView(sleeptip: $sleeptip, lighttip: $lighttip, noisetip: $noisetip)
                        }
                    }
                    Button {
                        sleepTime = Date.now
                        withAnimation { showSleepView = true }
                    } label: {
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.red)
                            .frame(width: 380, height: 70)
                            .overlay(
                                Text("Sleep Now")
                                    .foregroundColor(.white)
                                    .bold()
                            )
                    }
                    .glassEffect(in: RoundedRectangle(cornerRadius: 40))
                    NavigationLink {
                        DurationView()
                    } label: {
                        RoundedRectangle(cornerRadius: 14)
                            .frame(width: 380, height: 200)
                            .overlay(
                                VStack {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Duration")
                                                .foregroundColor(.white)
                                                .font(.title)
                                                .bold()
                                            Text("TODAY")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .bold()
                                        }
                                        Spacer()
                                        ZStack {
                                            ActivityRingView(progress: $progress)
                                                .animation(.easeOut(duration: 1.2), value: progress)
                                            Text(durationSlept)
                                                .foregroundColor(.white)
                                                .font(.title2)
                                                .bold()
                                        }
                                    }
                                }
                                    .padding()
                            )
                    }
                    .foregroundColor(Color.gray.opacity(0.2))
                    .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    NavigationLink {
                        LightView()
                    } label: {
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
                                    .padding()
                                    VStack {
                                        HStack {
                                            Image(systemName: "lightbulb.fill")
                                                .resizable()
                                                .frame(width: 34, height: 55)
                                                .foregroundStyle(.white)
                                            ForEach(0..<10) { index in
                                                Rectangle()
                                                    .frame(width: 14, height: 40)
                                                    .foregroundStyle(index < lightFilledBlocks ? Color.yellow : Color.clear)
                                                    .overlay(
                                                        Rectangle()
                                                            .stroke(Color.primary, lineWidth: 2)
                                                    )
                                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                            )
                            .foregroundColor(Color.gray.opacity(0.2))
                            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    }
                    NavigationLink {
                        NoiseView()
                    } label: {
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
                                                    .foregroundStyle(index < noiseFilledBlocks ? Color.white : Color.clear)
                                                    .overlay(
                                                        Rectangle()
                                                            .stroke(Color.primary, lineWidth: 2)
                                                    )
                                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                            )
                    }
                    .foregroundColor(Color.gray.opacity(0.2))
                    .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    .navigationTitle("Home")
                }
                .preferredColorScheme(.dark)
                .scrollIndicators(.hidden)
                .onAppear {
                    updateDurationRing()
                    updateTips()
                    updateLightRing()
                    updateNoiseRing()
                    if !hasSeenSheet { showSheet = true }
                }
                .onChange(of: durationData) {
                    updateDurationRing()
                }
                .onChange(of: lightData) {
                    updateLightRing()
                }
                .onChange(of: noiseData) {
                    updateNoiseRing()
                }
                .sheet(isPresented: $showSheet) {
                    GuidedAccessSheet(hasSeenSheet: $hasSeenSheet)
                        .interactiveDismissDisabled()
                }
            }
        } else {
            SleepView(showSleepView: $showSleepView, sleepTime: $sleepTime)
        }
    }
    
    func updateDurationRing() {
        let calendar = Calendar.current
        guard let todayEntry = durationData.first(where: { calendar.isDate($0.date, inSameDayAs: Date()) }) else {
            durationSlept = "0min"
            withAnimation { progress = 0.0 }
            return
        }
        let duration = todayEntry.duration
        let totalMinutes = Int(duration * 60)
        if totalMinutes < 60 {
            durationSlept = "\(totalMinutes)min"
        } else {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            durationSlept = minutes == 0 ? "\(hours)h" : "\(hours)h \(minutes)min"
        }
        withAnimation { progress = CGFloat(duration / 10) }
    }
    
    func updateLightRing() {
        var wake = setTimeToWakeUp
        let sleep = sleepTime
        if wake <= sleep {
            wake = Calendar.current.date(byAdding: .day, value: 1, to: wake)!
        }
        let lightInRange = lightData.filter { $0.date >= sleep && $0.date <= wake }
        let totalLight = lightInRange.reduce(0) { $0 + $1.light }
        let clampedLight = min(max(totalLight, 0), 100)
        lightFilledBlocks = Int((clampedLight / 100 * 10).rounded())
    }
    
    func updateNoiseRing() {
        var wake = setTimeToWakeUp
        let sleep = sleepTime
        if wake <= sleep {
            wake = Calendar.current.date(byAdding: .day, value: 1, to: wake)!
        }
        let noiseInRange = noiseData.filter { $0.date >= sleep && $0.date <= wake }
        let totalNoise = noiseInRange.reduce(0) { $0 + $1.noise }
        let clampedNoise = min(max(totalNoise, 0), 100)
        noiseFilledBlocks = Int((clampedNoise / 100 * 10).rounded())
    }
    
    func updateTips() {
        let today = Date()
        let duration = durationData.filter {
            Calendar.current.isDate($0.date, equalTo: today, toGranularity: .day)
        }.map { $0.duration }.reduce(0, +)
        let light = lightData.filter {
            Calendar.current.isDate($0.date, equalTo: today, toGranularity: .day)
        }.map { $0.light }.reduce(0, +)
        let noise = noiseData.filter {
            Calendar.current.isDate($0.date, equalTo: today, toGranularity: .day)
        }.map { $0.noise }.reduce(0, +)
        if duration > 10 { sleeptip = "Too much sleep 😴" }
        else if duration >= 8 { sleeptip = "Great amount of sleep! 👍" }
        else { sleeptip = "Try to sleep a bit more 😪" }
        switch light {
        case ...10: lighttip = "Perfect darkness level 🌙"
        case ...40: lighttip = "Slightly bright room, still okay 🫤"
        case ...80: lighttip = "A bit bright, try dimming 💡"
        default: lighttip = "Too much light! Can harm sleep 😵‍💫"
        }
        switch noise {
        case ...30: noisetip = "Very quiet environment 😌"
        case ...40: noisetip = "Some noise detected, acceptable 🤨"
        case ...55: noisetip = "Noise might disturb sleep 🫨"
        default: noisetip = "Very loud! Reduce noise ⚠️"
        }
    }
}


#Preview {
    ContentView()
}

