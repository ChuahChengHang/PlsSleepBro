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
