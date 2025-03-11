//
//  Alarm.swift
//  CheckList
//
//  Created by JIDTP1408 on 11/03/25.
//

import Foundation
import SwiftUI

struct Alarm: Identifiable, Codable {
    var id = UUID()
    var time: Date
    var label: String
}
