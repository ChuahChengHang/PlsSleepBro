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
                    } else if selectedTimeScale == .month {
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
                    } else if selectedTimeScale == .sixmonths {
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
                    } else {
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
                                } else if selectedTimeScale == .month {
                                    DurationMonthView(weeklyAverage: $weeklyAverage, weekOffset: $monthOffset)
                                } else if selectedTimeScale == .sixmonths {
                                    SixMonthsView(average: $sixMonthlyAverage, offset: $sixMonthOffset)
                                } else {
                                    DurationYearView(average: $monthlyAverage, offset: $yearOffset)
                                }
                            } else {
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
                    VStack {
                        if selectedTimeScale == .week {
                            Text("TODAY")
                                .foregroundStyle(.gray)
                                .font(.title)
                            Text("\(String(format: "%.1f", hoursSlept))h / 10h")
                                .font(.largeTitle)
                        } else if selectedTimeScale == .month {
                            Text("THIS WEEK")
                                .foregroundStyle(.gray)
                                .font(.title)
                            Text("\(String(format: "%.1f", hoursSlept))h / 70h")
                                .font(.largeTitle)
                        } else if selectedTimeScale == .sixmonths {
                            Text("THIS MONTH")
                                .foregroundStyle(.gray)
                                .font(.title)
                            Text("\(String(format: "%.1f", hoursSlept))h / 280h")
                                .font(.largeTitle)
                        } else {
                            Text("THIS MONTH")
                                .foregroundStyle(.gray)
                                .font(.title)
                            Text("\(String(format: "%.1f", hoursSlept))h / 280h")
                                .font(.largeTitle)
                        }
                        Text(progress * 100.0 == 0 ? "0%" : "\(Int(progress * 100.0))%")
                            .foregroundStyle(.white)
                            .font(.subheadline)
                            .bold()
                    }
                }
                .padding()
                .onAppear {
                    updateHoursSlept()
                }
                .onChange(of: durationData) {
                    updateHoursSlept()
                }
                .onChange(of: selectedTimeScale) {
                    updateHoursSlept()
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
                    )!
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "d MMM"
                    dateText = "\(formatter.string(from: startOfSelectedPeriod)) – \(formatter.string(from: endOfSelectedPeriod))"
                }
                .onChange(of: yearOffset) {
                    let calendar = Calendar.current
                    let today = Date()
                    
                    let startOfYear = calendar.date(
                        from: calendar.dateComponents([.year], from: today)
                    )!
                    
                    let startOfSelectedPeriod = calendar.date(
                        byAdding: .year,
                        value: yearOffset,
                        to: startOfYear
                    )!
                    
                    let endOfSelectedPeriod = calendar.date(
                        byAdding: .year,
                        value: 1,
                        to: startOfSelectedPeriod
                    )!
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "d MMM"
                    dateText = "\(formatter.string(from: startOfSelectedPeriod)) – \(formatter.string(from: endOfSelectedPeriod))"
                }
                Spacer()
            }
            .navigationTitle("Sleep Duration")
        }
        .preferredColorScheme(.dark)
    }

    func updateHoursSlept() {
        let calendar = Calendar.current
        let today = Date()
        var startDate: Date
        var endDate: Date
        var maxHours: Double

        switch selectedTimeScale {
        case .week:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            startDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfWeek)!
            endDate = calendar.date(byAdding: .day, value: 7, to: startDate)!
            maxHours = 10
        case .month:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
            startDate = calendar.date(byAdding: .month, value: monthOffset, to: startOfMonth)!
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
            maxHours = 70
        case .sixmonths:
            let startOfSixMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
            startDate = calendar.date(byAdding: .month, value: sixMonthOffset * 6, to: startOfSixMonth)!
            endDate = calendar.date(byAdding: .month, value: 6, to: startDate)!
            maxHours = 280
        case .year:
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: today))!
            startDate = calendar.date(byAdding: .year, value: yearOffset, to: startOfYear)!
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate)!
            maxHours = 560
        }

        hoursSlept = durationData
            .filter { $0.date >= startDate && $0.date < endDate }
            .map { $0.duration }
            .reduce(0, +)

        progress = CGFloat(min(hoursSlept / maxHours, 1.0))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        dateText = "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
    }
}


#Preview {
    DurationView()
}
