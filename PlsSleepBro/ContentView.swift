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
                        if sleeptip == "" || lighttip == "" || noisetip == "" {
                            
                        }else {
                            TipsView(sleeptip: $sleeptip, lighttip: $lighttip, noisetip: $noisetip)
                        }
                    }
                    Button {
                        sleepTime = Date.now
                        withAnimation {
                            showSleepView = true
                        }
                    }label: {
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.red)
                            .frame(width: 380, height: 70)
                            .overlay(
                                Text("Sleep Now")
                                    .foregroundStyle(.white)
                            )
                        
                    }
                    .glassEffect(in: RoundedRectangle(cornerRadius: 40))
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
                                                .animation(.easeOut(duration: 1.2), value: progress)
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
                        LightView()
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
                            .foregroundStyle(Color.gray.opacity(0.2))
                            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    }
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
                    .foregroundStyle(Color.gray.opacity(0.2))
                    .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    .navigationTitle("Home")
                }
                .preferredColorScheme(.dark)
                .scrollIndicators(.hidden)
                .onAppear {
                    progress = 0.0
                    if hasSeenSheet {
                        return
                    }else {
                        showSheet = true
                    }
                    if !durationData.isEmpty {
                        let data = durationData
                        let index = data.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: .now) })
                        if let index = index {
                            let duration = data[index].duration
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
                        }
                    } else {
                        progress = 0.0
                    }
                    let calendar = Calendar.current
                    
                    let sleep = sleepTime
                    var wake = setTimeToWakeUp
                    
                    if wake <= sleep {
                        wake = calendar.date(byAdding: .day, value: 1, to: wake)!
                    }
                    
                    let noiseInRange = noiseData.filter { $0.date >= sleep && $0.date <= wake }
                    let totalNoise = noiseInRange.reduce(0) { $0 + $1.noise }
                    let clampedNoise = min(max(totalNoise, 0), 100)
                    noiseFilledBlocks = Int((clampedNoise / 100 * 10).rounded())
                    
                    let lightInRange = lightData.filter { $0.date >= sleep && $0.date <= wake }
                    let totalLight = lightInRange.reduce(0) { $0 + $1.light }
                    let clampedLight = min(max(totalLight, 0), 100)
                    lightFilledBlocks = Int((clampedLight / 100 * 10).rounded())
                    updateTips()
                }
                
                .onChange(of: durationData) {
                    if !durationData.isEmpty {
                        let data = durationData
                        let index = data.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: .now) })
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
                .onChange(of: noiseData) {
                    let calendar = Calendar.current
                    
                    let sleep = sleepTime
                    var wake = setTimeToWakeUp
                    
                    if wake <= sleep {
                        wake = calendar.date(byAdding: .day, value: 1, to: wake)!
                    }
                    
                    let noiseInRange = noiseData.filter { $0.date >= sleep && $0.date <= wake }
                    let totalNoise = noiseInRange.reduce(0) { $0 + $1.noise }
                    let clampedNoise = min(max(totalNoise, 0), 100)
                    noiseFilledBlocks = Int((clampedNoise / 100 * 10).rounded())
                }
                .onChange(of: lightData) {
                    let calendar = Calendar.current
                    
                    let sleep = sleepTime
                    var wake = setTimeToWakeUp
                    
                    if wake <= sleep {
                        wake = calendar.date(byAdding: .day, value: 1, to: wake)!
                    }
                    let lightInRange = lightData.filter { $0.date >= sleep && $0.date <= wake }
                    let totalLight = lightInRange.reduce(0) { $0 + $1.light }
                    let clampedLight = min(max(totalLight, 0), 100)
                    lightFilledBlocks = Int((clampedLight / 100 * 10).rounded())
                }
                .sheet(isPresented: $showSheet) {
                    GuidedAccessSheet(hasSeenSheet: $hasSeenSheet)
                        .interactiveDismissDisabled()
                }
            }
        }else {
            SleepView(showSleepView: $showSleepView, sleepTime: $sleepTime)
        }
    }
    func updateTips() {
        let today = Date.now
        let duration = durationData.filter {
            Calendar.current.isDate($0.date, equalTo: today, toGranularity: .day)
        }
            .map { $0.duration }
            .reduce(0, +)
        let light = lightData.filter {
            Calendar.current.isDate($0.date, equalTo: today, toGranularity: .day)
        }
            .map { $0.light }
            .reduce(0, +)
        let noise = noiseData.filter {
            Calendar.current.isDate($0.date, equalTo: today, toGranularity: .day)
        }
            .map { $0.noise }
            .reduce(0, +)
        if duration > 10 {
            sleeptip = "Too much sleep 😴"
        } else if duration >= 8 {
            sleeptip = "Great amount of sleep! 👍"
        } else {
            sleeptip = "Try to sleep a bit more 😪"
        }
        
        if light <= 10 {
            lighttip = "Perfect darkness level 🌙"
        } else if light <= 40 {
            lighttip = "Your room was slightly bright, but still okay.🫤"
        } else if light <= 80 {
            lighttip = "Your room was a bit bright. Try dimming the lights 💡"
        } else {
            lighttip = "Too much light! This can harm sleep quality 😵‍💫"
        }
        
        if noise <= 30 {
            noisetip = "Very quiet environment, ideal for sleep 😌"
            return
        } else if noise <= 40 {
            noisetip = "Some noise detected, but acceptable.🤨"
            return
        } else if noise <= 55 {
            noisetip = "Noise might have disturbed your sleep 🫨"
            return
        } else {
            noisetip = "Very loud environment! Try reducing noise ⚠️"
            return
        }
    }
}

#Preview {
    ContentView()
}

