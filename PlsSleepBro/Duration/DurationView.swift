//
//  DurationView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 17/11/25.
//

import SwiftUI
import Charts
import SwiftData

enum timeScale: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case sixmonths = "6 Months"
    case year = "Year"
}

struct DurationView: View {
    @Query private var durationData: [sleepDurationStruct]
    @State private var selectedTimeScale: timeScale = .week
    @State private var dailyAverage: Double = 0.0
    @State private var weeklyAverage: Double = 0.0
    @State private var sixMonthlyAverage: Double = 0.0
    @State private var monthlyAverage: Double = 0.0
    @State private var progress: CGFloat = 0.0
    @State private var hoursSlept: Double = 0.0
    @State private var weekOffset: Int = 0
    @State private var monthOffset: Int = 0
    @State private var sixMonthOffset: Int = 0
    @State private var yearOffset: Int = 0
    @State private var dateText: String = ""
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Picker("Time Schedule", selection: $selectedTimeScale) {
                        ForEach(timeScale.allCases, id: \.self) { value in
                            Text("\(value.rawValue)")
                        }
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: selectedTimeScale)
                    .pickerStyle(.segmented)
                    if selectedTimeScale == .week {
                        HStack {
                            VStack {
                                Text("DAILY AVERAGE")
                                    .foregroundStyle(.gray)
                                    .bold()
                                Text("\(String(format: "%.1f", dailyAverage)) Hours")
                                    .foregroundStyle(.red)
                                    .font(.title)
                                    .bold()
                                Text(dateText)
                                    .foregroundStyle(.gray)
                                    .bold()
                            }
                            Spacer()
                        }
                    }else if selectedTimeScale == .month {
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("WEEKLY AVERAGE")
                                    .foregroundStyle(.gray)
                                    .bold()
                                Text("\(String(format: "%.1f", weeklyAverage)) Hours")
                                    .foregroundStyle(.red)
                                    .font(.title)
                                    .bold()
                                Text(dateText)
                                    .foregroundStyle(.gray)
                                    .bold()
                            }
                            Spacer()
                        }
                    }else if selectedTimeScale == .sixmonths {
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("MONTHLY AVERAGE")
                                    .foregroundStyle(.gray)
                                    .bold()
                                Text("\(String(format: "%.1f", sixMonthlyAverage)) Hours")
                                    .foregroundStyle(.red)
                                    .font(.title)
                                    .bold()
                                Text(dateText)
                                    .foregroundStyle(.gray)
                                    .bold()
                            }
                            Spacer()
                        }
                    }else {
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("MONTHLY AVERAGE")
                                    .foregroundStyle(.gray)
                                    .bold()
                                Text("\(String(format: "%.1f", monthlyAverage)) Hours")
                                    .foregroundStyle(.red)
                                    .font(.title)
                                    .bold()
                                Text(dateText)
                                    .foregroundStyle(.gray)
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                }
                .padding()
                RoundedRectangle(cornerRadius: 18)
                    .fill(.quaternary)
                    .frame(width: 380, height: 400)
                    .overlay(
                        VStack {
                            if !durationData.isEmpty {
                                if selectedTimeScale == .week {
                                    DurationWeekView(dailyAverage: $dailyAverage, weekOffset: $weekOffset)
                                }else if selectedTimeScale == .month {
                                    DurationMonthView(weeklyAverage: $weeklyAverage, weekOffset: $monthOffset)
                                }else if selectedTimeScale == .sixmonths {
                                    SixMonthsView(average: $sixMonthlyAverage, offset: $sixMonthOffset)
                                }else {
                                    DurationYearView(average: $monthlyAverage, offset: $yearOffset)
                                }
                            }else {
                                Text("No Data Available")
                                    .foregroundStyle(.white)
                                    .font(.largeTitle)
                                    .bold()
                            }
                        }
                    )
                    .glassEffect(in: RoundedRectangle(cornerRadius: 18))
                ZStack {
                    ActivityRingView(progress: $progress)
                    if selectedTimeScale == .week {
                        VStack {
                            Text("TODAY")
                                .foregroundStyle(.gray)
                                .font(.title)
                            Text("\(String(format: "%.1f", hoursSlept))h / 10h")
                                .font(.largeTitle)
                            Text(progress * 100.0 == 0 ? "0%" : "\(Int(progress * 100.0))%")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                                .bold()
                        }
                    }else if selectedTimeScale == .month {
                        VStack {
                            Text("THIS WEEK")
                                .foregroundStyle(.gray)
                                .font(.title)
                            Text("\(String(format: "%.1f", hoursSlept))h / 70h")
                                .font(.largeTitle)
                            Text(progress * 100.0 == 0 ? "0%" : "\(Int(progress * 100.0))%")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                                .bold()
                        }
                    }else if selectedTimeScale == .sixmonths {
                        VStack {
                            Text("THIS MONTH")
                                .foregroundStyle(.gray)
                                .font(.title)
                            Text("\(String(format: "%.1f", hoursSlept))h / 280h")
                                .font(.largeTitle)
                            Text(progress * 100.0 == 0 ? "0%" : "\(Int(progress * 100.0))%")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                                .bold()
                        }
                    }else {
                        VStack {
                            Text("THIS MONTH")
                                .foregroundStyle(.gray)
                                .font(.title)
                            Text("\(String(format: "%.1f", hoursSlept))h / 280h")
                                .font(.largeTitle)
                            Text(progress * 100.0 == 0 ? "0%" : "\(Int(progress * 100.0))%")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                                .bold()
                        }
                    }
                }
                .padding()
                .onAppear {
                    if !durationData.isEmpty {
                        if selectedTimeScale == .week {
                            let today = Date.now
                            let calendar = Calendar.current
                            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                            hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfWeek, toGranularity: .day)}
                                .map { $0.duration }
                                .reduce(0, +)
                            let startOfCurrentWeek = calendar.date(
                                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
                            )!
                            let startDate = calendar.date(
                                byAdding: .weekOfYear,
                                value: -3,
                                to: startOfWeek
                            )!
                            let endDate = calendar.date(
                                byAdding: .day,
                                value: 27,
                                to: startDate
                            )!
                            let formatter = DateFormatter()
                            formatter.dateFormat = "d MMM"
                            dateText = "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
                            print("\(hoursSlept)")
                            progress = CGFloat(hoursSlept / 10)
                        }else if selectedTimeScale == .month {
                            let today = Date.now
                            let calendar = Calendar.current
                            let startOfCurrentWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                            hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfCurrentWeek, toGranularity: .weekOfYear)}
                                .map { $0.duration }
                                .reduce(0, +)
                            let startOfWeek = calendar.date(byAdding: .weekOfYear, value: monthOffset, to: startOfCurrentWeek)!
                            let startDate = calendar.date(
                                byAdding: .weekOfYear,
                                value: -3,
                                to: startOfWeek
                            )!
                            let endDate = calendar.date(
                                byAdding: .day,
                                value: 27,
                                to: startDate
                            )!
                            let formatter = DateFormatter()
                            formatter.dateFormat = "d MMM"
                            dateText = "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
                            print("\(hoursSlept)")
                            progress = CGFloat(hoursSlept / 70)
                        }else if selectedTimeScale == .sixmonths {
                            let today = Date.now
                            let calendar = Calendar.current
                            let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
                            hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfThisMonth, toGranularity: .month)
                            }
                            .map { $0.duration }
                            .reduce(0, +)
                            print("\(hoursSlept)")
                            progress = CGFloat(hoursSlept / 280)
                        }else {
                            let today = Date.now
                            let calendar = Calendar.current
                            let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
                            hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfThisMonth, toGranularity: .month)
                            }
                            .map { $0.duration }
                            .reduce(0, +)
                            print("\(hoursSlept)")
                            progress = CGFloat(hoursSlept / 280)
                        }
                    }else {
                        hoursSlept = 0.0
                    }
                }
                .onChange(of: selectedTimeScale) {
                    if selectedTimeScale == .week {
                        let today = Date.now
                        let calendar = Calendar.current
                        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                        hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfWeek, toGranularity: .day)}
                            .map { $0.duration }
                            .reduce(0, +)
                        print("\(hoursSlept)")
                        progress = CGFloat(hoursSlept / 10)
                    }else if selectedTimeScale == .month {
                        let today = Date.now
                        let calendar = Calendar.current
                        let startOfCurrentWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                        hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfCurrentWeek, toGranularity: .weekOfYear)}
                            .map { $0.duration }
                            .reduce(0, +)
                        print("\(hoursSlept)")
                        progress = CGFloat(hoursSlept / 70)
                    }else if selectedTimeScale == .sixmonths {
                        let today = Date.now
                        let calendar = Calendar.current
                        let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
                        hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfThisMonth, toGranularity: .month)
                        }
                        .map { $0.duration }
                        .reduce(0, +)
                        print("\(hoursSlept)")
                        progress = CGFloat(hoursSlept / 280)
                    }else {
                        let today = Date.now
                        let calendar = Calendar.current
                        let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
                        hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfThisMonth, toGranularity: .month)
                        }
                        .map { $0.duration }
                        .reduce(0, +)
                        print("\(hoursSlept)")
                        progress = CGFloat(hoursSlept / 280)
                    }
                }
                .onChange(of: dailyAverage) {
                    let today = Date.now
                    let calendar = Calendar.current
                    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                    hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfWeek, toGranularity: .day)}
                        .map { $0.duration }
                        .reduce(0, +)
                    print("\(hoursSlept)")
                    progress = CGFloat(hoursSlept / 10)
                }
                .onChange(of: weeklyAverage) {
                    let today = Date.now
                    let calendar = Calendar.current
                    let startOfCurrentWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                    hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfCurrentWeek, toGranularity: .weekOfYear)}
                        .map { $0.duration }
                        .reduce(0, +)
                    print("\(hoursSlept)")
                    progress = CGFloat(hoursSlept / 70)
                }
                .onChange(of: sixMonthlyAverage) {
                    let today = Date.now
                    let calendar = Calendar.current
                    let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
                    hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfThisMonth, toGranularity: .month)
                    }
                    .map { $0.duration }
                    .reduce(0, +)
                    print("\(hoursSlept)")
                    progress = CGFloat(hoursSlept / 280)
                }
                .onChange(of: monthlyAverage) {
                    let today = Date.now
                    let calendar = Calendar.current
                    let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
                    hoursSlept = durationData.filter { calendar.isDate($0.date, equalTo: startOfThisMonth, toGranularity: .month)
                    }
                    .map { $0.duration }
                    .reduce(0, +)
                    print("\(hoursSlept)")
                    progress = CGFloat(hoursSlept / 280)
                }
                .onChange(of: weekOffset) {
                    let calendar = Calendar.current
                    let today = Date()
                    let startOfCurrentWeek = calendar.date(
                        from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
                    )!
                    
                    let startOfWeek = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfCurrentWeek)!
                    let startDate = calendar.date(
                        byAdding: .weekOfYear,
                        value: -3,
                        to: startOfWeek
                    )!
                    let endDate = calendar.date(
                        byAdding: .day,
                        value: 27,
                        to: startDate
                    )!
                    let formatter = DateFormatter()
                    formatter.dateFormat = "d MMM"
                    dateText = "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
                }
                .onChange(of: monthOffset) {
                    let calendar = Calendar.current
                    let today = Date()
                    let startOfCurrentWeek = calendar.date(
                        from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
                    )!
                    
                    let startOfWeek = calendar.date(byAdding: .weekOfYear, value: monthOffset, to: startOfCurrentWeek)!
                    let startDate = calendar.date(
                        byAdding: .weekOfYear,
                        value: -3,
                        to: startOfWeek
                    )!
                    let endDate = calendar.date(
                        byAdding: .day,
                        value: 27,
                        to: startDate
                    )!
                    let formatter = DateFormatter()
                    formatter.dateFormat = "d MMM"
                    dateText = "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
                }
                .onChange(of: sixMonthOffset) {
                    let calendar = Calendar.current
                    let today = Date()
                    
                    let startOfMonth = calendar.date(
                        from: calendar.dateComponents([.year, .month], from: today)
                    )!
                    
                    let startOfSelectedPeriod = calendar.date(
                        byAdding: .month,
                        value: sixMonthOffset * 6,
                        to: startOfMonth
                    )!
                    
                    let endOfSelectedPeriod = calendar.date(
                        byAdding: .month,
                        value: 6,
                        to: startOfSelectedPeriod
                    )!.addingTimeInterval(-1)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "d MMM"
                    
                    let startString = formatter.string(from: startOfSelectedPeriod)
                    let endString = formatter.string(from: endOfSelectedPeriod)
                    
                    dateText = "\(startString) – \(endString)"
                }
                .onChange(of: yearOffset) {
                    let calendar = Calendar.current
                    let today = Date()
                    
                    let startOfMonth = calendar.date(
                        from: calendar.dateComponents([.year, .month], from: today)
                    )!
                    
                    let startOfSelectedPeriod = calendar.date(
                        byAdding: .month,
                        value: yearOffset * 6,
                        to: startOfMonth
                    )!
                    
                    let endOfSelectedPeriod = calendar.date(
                        byAdding: .month,
                        value: 6,
                        to: startOfSelectedPeriod
                    )!.addingTimeInterval(-1)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "d MMM"
                    
                    let startString = formatter.string(from: startOfSelectedPeriod)
                    let endString = formatter.string(from: endOfSelectedPeriod)
                    
                    dateText = "\(startString) – \(endString)"
                }
                Spacer()
                
            }
            .navigationTitle("Sleep Duration")
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    DurationView()
}
