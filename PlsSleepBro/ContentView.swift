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
    @AppStorage("showSleepView") private var showSleepView: Bool = false
    var body: some View {
        if !showSleepView {
            NavigationStack {
                ScrollView {
                    TipsView()
                    Button {
                        sleepTime = Date.now
                        withAnimation(.easeInOut) { showSleepView = true }
                    } label: {
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.red)
                            .shadow(radius: 8, y: 4)
                            .frame(width: 380, height: 70)
                            .overlay(
                                Text("Sleep Now")
                                    .foregroundColor(.white)
                                    .bold()
                            )
                    }
                    .glassEffect(in: RoundedRectangle(cornerRadius: 40))
                    .padding(5)
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
                                    .padding(25)
                            )
                    }
                    .foregroundColor(Color.gray.opacity(0.2))
                    .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
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
                                                .foregroundStyle(.yellow)
                                                .padding(.horizontal)
                                            ForEach(0..<10) { index in
                                                if index == 3{
                                                    HStack {
                                                        VStack {
                                                            Rectangle()
                                                                .frame(width: 2, height: 90)
                                                                .foregroundStyle(Color.green)
                                                            Text("Ideal")
                                                                .font(.caption)
                                                                .foregroundColor(.green)
                                                        }
                                                        .padding([.trailing, .leading, .bottom], -14)
                                                        Rectangle()
                                                            .frame(width: 14, height: 40)
                                                            .foregroundStyle(index < lightFilledBlocks ? Color.yellow : Color.clear)
                                                            .overlay(
                                                                Rectangle()
                                                                    .stroke(Color.primary, lineWidth: 2)
                                                            )
                                                            .clipShape(RoundedRectangle(cornerRadius: 3))
                                                    }
                                                }else {
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
                                    }
                                    Spacer()
                                }
                            )
                    }
                    .foregroundColor(Color.gray.opacity(0.2))
                    .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                    .padding(2)
                    NavigationLink {
                        NoiseView()
                    } label: {
                        let idealNoiseBlocks = 3
                        
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
                                                .padding(.horizontal)
                                            ForEach(0..<10) { index in
                                                if index == 3{
                                                    HStack {
                                                        VStack {
                                                            Rectangle()
                                                                .frame(width: 2, height: 90)
                                                                .foregroundStyle(Color.green)
                                                            Text("Ideal")
                                                                .font(.caption)
                                                                .foregroundColor(.green)
                                                        }
                                                        .padding([.trailing, .leading, .bottom], -14)
                                                        Rectangle()
                                                            .frame(width: 14, height: 40)
                                                            .foregroundStyle(index < noiseFilledBlocks ? Color.white : Color.clear)
                                                            .overlay(
                                                                Rectangle()
                                                                    .stroke(Color.primary, lineWidth: 2)
                                                            )
                                                            .clipShape(RoundedRectangle(cornerRadius: 3))
                                                    }
                                                }else {
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
                                    }
                                    Spacer()
                                }
                            )
                    }
                    .foregroundColor(Color.gray.opacity(0.2))
                    .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                }
                .navigationTitle("Home")
                .preferredColorScheme(.dark)
                .scrollIndicators(.hidden)
                .onAppear {
                    updateDurationRing()
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
            withAnimation(.easeInOut) {
                SleepView(showSleepView: $showSleepView, sleepTime: $sleepTime)
            }
        }
    }
    
    func updateDurationRing() {
        let calendar = Calendar.current
        let today = Date.now
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let startDate = calendar.date(byAdding: .weekOfYear, value: 0, to: startOfWeek)!
        let endDate = calendar.date(byAdding: .day, value: 7, to: startDate)!
        var duration = durationData
            .filter { $0.date >= startDate && $0.date < endDate }
            .map { $0.duration }
            .reduce(0, +)
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
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sleep = today.addingTimeInterval(sleepTime.timeIntervalSince(calendar.startOfDay(for: sleepTime)))
        var wake = today.addingTimeInterval(setTimeToWakeUp.timeIntervalSince(calendar.startOfDay(for: setTimeToWakeUp)))
        
        if wake <= sleep {
            wake = calendar.date(byAdding: .day, value: 1, to: wake)!
        }
        
        let lightInRange = lightData.filter { $0.date >= sleep && $0.date <= wake }
        let totalLight = lightInRange.reduce(0) { $0 + $1.light }
        let clampedLight = min(max(totalLight, 0), 100)
        lightFilledBlocks = Int((clampedLight / 100 * 10).rounded())
    }
    
    func updateNoiseRing() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sleep = today.addingTimeInterval(sleepTime.timeIntervalSince(calendar.startOfDay(for: sleepTime)))
        var wake = today.addingTimeInterval(setTimeToWakeUp.timeIntervalSince(calendar.startOfDay(for: setTimeToWakeUp)))
        
        if wake <= sleep {
            wake = calendar.date(byAdding: .day, value: 1, to: wake)!
        }
        
        let noiseInRange = noiseData.filter { $0.date >= sleep && $0.date <= wake }
        let totalNoise = noiseInRange.reduce(0) { $0 + $1.noise }
        let clampedNoise = min(max(totalNoise, 0), 100)
        noiseFilledBlocks = Int((clampedNoise / 100 * 10).rounded())
    }
}


#Preview {
    ContentView()
}

