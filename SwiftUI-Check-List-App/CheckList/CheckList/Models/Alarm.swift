//
//  Alarm.swift
//  CheckList
//
//  Created by JIDTP1408 on 11/03/25.
//

import Foundation

struct Alarm: Identifiable, Codable {
    var id = UUID()  // ✅ Unique ID for SwiftUI List
    var time: Date
    var label: String
}
