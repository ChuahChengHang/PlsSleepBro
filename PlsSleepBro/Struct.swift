//
//  Struct.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 17/11/25.
//

import Foundation

struct sleepDurationStruct: Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var duration: Int
}
