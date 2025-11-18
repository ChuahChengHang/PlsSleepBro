//
//  PlsSleepBroApp.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 15/11/25.
//

import SwiftUI
import SwiftData

@main
struct PlsSleepBroApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [sleepDurationStruct.self])
    }
}
