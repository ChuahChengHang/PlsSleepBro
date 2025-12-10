//
//  DurationView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 17/11/25.
//

import SwiftUI
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
            VStack {
                VStack {
                    Picker("Time Schedule", selection: $selectedTimeScale) {
                        ForEach(timeScale.allCases, id: \.self) { value in
                            Text("\(value.rawValue)")
                        }
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: selectedTimeScale)
                    .pickerStyle(.segmented)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            switch selectedTimeScale {
                            case .week:
                                Text("DAILY AVERAGE")
                                    .foregroundStyle(.gray)
                                    .bold()
                                Text("\(String(format: "%.1f", dailyAverage)) Hours")
                                    .foregroundStyle(.red)
                                    .font(.title)
                                    .bold()
                            case .month:
                                Text("WEEKLY AVERAGE")
                                    .foregroundStyle(.gray)
                                    .bold()
                                Text("\(String(format: "%.1f", weeklyAverage)) Hours")
                                    .foregroundStyle(.red)
                                    .font(.title)
                                    .bold()
                            case .sixmonths:
                                Text("MONTHLY AVERAGE")
                                    .foregroundStyle(.gray)
                                    .bold()
                                Text("\(String(format: "%.1f", sixMonthlyAverage)) Hours")
                                    .foregroundStyle(.red)
                                    .font(.title)
                                    .bold()
                            case .year:
                                Text("MONTHLY AVERAGE")
                                    .foregroundStyle(.gray)
                                    .bold()
                                Text("\(String(format: "%.1f", monthlyAverage)) Hours")
                                    .foregroundStyle(.red)
                                    .font(.title)
                                    .bold()
                            }
                            Text(dateText)
                                .foregroundStyle(.gray)
                                .bold()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 6)
                }
                .padding()
                
                RoundedRectangle(cornerRadius: 18)
                    .fill(.quaternary)
                    .frame(width: 380, height: 400)
                    .overlay(
                        VStack {
                            if !durationData.isEmpty {
                                switch selectedTimeScale {
                                case .week:
                                    DurationWeekView(dailyAverage: $dailyAverage, weekOffset: $weekOffset)
                                case .month:
                                    DurationMonthView(weeklyAverage: $weeklyAverage, weekOffset: $monthOffset)
                                case .sixmonths:
                                    SixMonthsView(average: $sixMonthlyAverage, offset: $sixMonthOffset)
                                case .year:
                                    DurationYearView(average: $monthlyAverage, offset: $yearOffset)
                                }
                            } else {
                                ContentUnavailableView {
                                    Label("No Data", systemImage: "xmark.circle")
                                } description: {
                                    Text("Graph of your sleep duration will appear here.")
                                    //                                        .foregroundStyle(.white)
                                    //                                        .font(.largeTitle)
                                    //                                        .bold()
                                }
                            }
                        }
                    )
                    .glassEffect(in: RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal)
                ZStack {
                    HorizontalProgessView(progress: $progress)
                    VStack {
                        switch selectedTimeScale {
                        case .week:
                            Text("\(String(format: "%.1f", hoursSlept))h / 70h")
                                .font(.title)
                                .padding(13)
                        case .month:
                            Text("\(String(format: "%.1f", hoursSlept))h / 300h")
                                .font(.title)
                                .padding(13)
                        case .sixmonths:
                            Text("\(String(format: "%.1f", hoursSlept))h / 1825h")
                                .font(.title)
                                .padding(13)
                        case .year:
                            //                                .foregroundStyle(.gray)
                            //                                .font(.title)
                            Text("\(String(format: "%.1f", hoursSlept))h / 3650h")
                                .font(.title)
                                .padding(13)
                        }
                        Text(progress * 100 == 0 ? "0%" : "\(Int(progress * 100))%")
                            .foregroundStyle(.white)
                            .font(.subheadline)
                            .bold()
                            .padding(.bottom, 13)
                    }
                }
                .padding()
                .onAppear { updateHoursSlept() }
                .onChange(of: durationData) {
                    updateHoursSlept()
                }
                .onChange(of: selectedTimeScale) {
                    updateHoursSlept()
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
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            startDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startDate)!
            endDate = calendar.date(byAdding: .day, value: 7, to: startDate)!
            maxHours = 24 * 7
            
        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
            startDate = calendar.date(byAdding: .month, value: monthOffset, to: startDate)!
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
            let daysInMonth = calendar.range(of: .day, in: .month, for: startDate)!.count
            maxHours = Double(daysInMonth * 10)
            
        case .sixmonths:
            let endMonth = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: today)
                )!
                let startMonth = calendar.date(
                    byAdding: .month,
                    value: -5 + (sixMonthOffset * -6),
                    to: endMonth
                )!
                startDate = startMonth
                endDate = calendar.date(byAdding: .month, value: 6, to: startMonth)!
                let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 180
                maxHours = Double(days * 10)
            
        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: today))!
            startDate = calendar.date(byAdding: .year, value: yearOffset, to: startDate)!
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate)!
            let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 365
            maxHours = Double(days * 10)
        }
        
        hoursSlept = durationData
            .filter { $0.date >= startDate && $0.date < endDate }
            .map { $0.duration }
            .reduce(0, +)
        
        if selectedTimeScale == .week {
            progress = CGFloat(hoursSlept / 70 / 10)
        }else if selectedTimeScale == .month {
            progress = CGFloat(hoursSlept / 300 / 10)
        }else if selectedTimeScale == .sixmonths {
            progress = CGFloat(hoursSlept / 1825 / 10)
        }else {
            progress = CGFloat(hoursSlept / 3650 / 10)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        dateText = "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate.addingTimeInterval(-1)))"
    }
}



#Preview {
    DurationView()
}

