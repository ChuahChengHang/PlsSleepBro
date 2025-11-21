//
//  Struct.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 17/11/25.
//

import Foundation
import SwiftData

@Model
class sleepDurationStruct: Equatable {
    var date: Date
    var duration: Double
    
    init(date: Date, duration: Double) {
        self.date = date
        self.duration = duration
    }
    static func == (lhs: sleepDurationStruct, rhs: sleepDurationStruct) -> Bool {
        return lhs.date == rhs.date
    }
}

@Model
class noiseStruct: Equatable {
//    @Attribute(.unique) var id: UUID = UUID()
    var date: Date
    var noise: Double
    
    init(date: Date, noise: Double) {
        self.date = date
        self.noise = noise
    }
    static func == (lhs: noiseStruct, rhs: noiseStruct) -> Bool {
        return lhs.date == rhs.date
    }
}

@Model
class lightStruct: Equatable {
//    @Attribute(.unique) var id: UUID = UUID()
    var date: Date
    var light: Double
    
    init(date: Date, light: Double) {
        self.date = date
        self.light = light
    }
    static func == (lhs: lightStruct, rhs: lightStruct) -> Bool {
        return lhs.date == rhs.date
    }
}
