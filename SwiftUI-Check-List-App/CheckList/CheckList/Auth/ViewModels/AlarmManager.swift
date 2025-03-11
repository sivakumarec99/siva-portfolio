//
//  AlarmManager.swift
//  CheckList
//
//  Created by JIDTP1408 on 11/03/25.
//

import Foundation
class AlarmManager: ObservableObject {
    @Published var alarms: [Alarm] = [] // ✅ This will update the UI automatically

    private let key = "savedAlarms"

    init() {
        loadAlarms()
    }

    func addAlarm(time: Date, label: String) {
        let newAlarm = Alarm(time: time, label: label)
        alarms.append(newAlarm)
        saveAlarms()
    }

    func deleteAlarm(at index: Int) {
        alarms.remove(at: index)
        saveAlarms()
    }

    private func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private func loadAlarms() {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Alarm].self, from: savedData) {
            DispatchQueue.main.async {
                self.alarms = decoded // ✅ Make sure UI updates
            }
        }
    }
}
