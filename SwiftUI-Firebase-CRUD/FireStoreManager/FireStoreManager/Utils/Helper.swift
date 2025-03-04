//
//  Helper.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 04/03/25.
//

import Foundation
func formatTime(_ timeInterval: TimeInterval) -> String {
    let seconds = Int(timeInterval) % 60
    let minutes = (Int(timeInterval) / 60) % 60
    let hours = (Int(timeInterval) / 3600)
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}
