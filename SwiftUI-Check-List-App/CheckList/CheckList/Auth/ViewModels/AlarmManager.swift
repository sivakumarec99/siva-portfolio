//
//  AlarmManager.swift
//  CheckList
//
//  Created by JIDTP1408 on 11/03/25.
//

import Foundation
import CoreData
import SwiftUI

class AlarmManager: ObservableObject {
    static let shared = AlarmManager()
    
    @Published var alarms: [AlarmEntity] = []
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        fetchAlarms() // Load alarms on init
    }
    
    // ✅ Fetch Alarms
    func fetchAlarms() {
        let request: NSFetchRequest<AlarmEntity> = AlarmEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AlarmEntity.time, ascending: true)]
        
        do {
            alarms = try viewContext.fetch(request)
        } catch {
            print("❌ Error fetching alarms: \(error.localizedDescription)")
        }
    }
    
    func addAlarm(time: Date, name: String, sound: String, snoozeDuration: Int, repeatDays: Set<String>, background: String, isEnabled: Bool) {
        let newAlarm = AlarmEntity(context: viewContext)
        newAlarm.id = UUID()
        newAlarm.time = time
        newAlarm.name = name
        newAlarm.sound = sound
        newAlarm.snoozeDuration = Int16(snoozeDuration)  // Ensure Int16 conversion
        newAlarm.repeatDays = repeatDays.joined(separator: ",") // Convert Set<String> to a single string
        newAlarm.background = background
        newAlarm.isEnabled = isEnabled

        saveContext()
    }
    
    // ✅ Delete Alarm
    func deleteAlarm(_ alarm: AlarmEntity) {
        viewContext.delete(alarm)
        saveContext()
    }
    func updateAlarm(_ alarm: AlarmEntity, time: Date, name: String, sound: String, snoozeDuration: Int, repeatDays: Set<String>, background: String, isEnabled: Bool) {
        alarm.time = time
        alarm.name = name
        alarm.sound = sound
        alarm.snoozeDuration = Int16(snoozeDuration)  // Convert to Int16 for Core Data
        alarm.repeatDays = repeatDays.joined(separator: ",") // Convert Set<String> to a single string
        alarm.background = background
        alarm.isEnabled = isEnabled
        
        saveContext()
    }
    // ✅ Save Context
    private func saveContext() {
        do {
            try viewContext.save()
            fetchAlarms() // Refresh list after changes
        } catch {
            print("❌ Error saving Core Data: \(error.localizedDescription)")
        }
    }
}
