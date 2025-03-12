//
//  AlarmListView.swift
//  CheckList
//
//  Created by JIDTP1408 on 11/03/25.
//

import SwiftUI
import CoreData

struct AlarmListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: AlarmEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \AlarmEntity.time, ascending: true)]
    ) var alarms: FetchedResults<AlarmEntity>
    
    @State private var selectedAlarm: AlarmEntity?
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            List {
                ForEach(alarms, id: \.id) { alarm in
                    Button(action: {
                        selectedAlarm = alarm
                        isEditing = true
                    }) {
                        HStack {
                            Toggle("", isOn: Binding(
                                get: { alarm.isEnabled },
                                set: { newValue in
                                    toggleAlarm(alarm, isEnabled: newValue)
                                }
                            ))
                            .labelsHidden()
                            
                            VStack(alignment: .leading) {
                                Text(alarm.time ?? Date(), style: .time)
                                    .font(.headline)
                                if let label = alarm.name, !label.isEmpty {
                                    Text(label)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteAlarm)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Alarms")
            .sheet(isPresented: $isEditing) {
                if let selectedAlarm = selectedAlarm {
                    AddAlarmView(alarmManager: AlarmManager())
                }
            }
        }
    }
    
    // ✅ Toggle Alarm Function (Updates Core Data)
    private func toggleAlarm(_ alarm: AlarmEntity, isEnabled: Bool) {
        alarm.isEnabled = isEnabled
        saveContext()
    }

    // ✅ Delete Alarm Function
    private func deleteAlarm(at offsets: IndexSet) {
        for index in offsets {
            let alarm = alarms[index]
            viewContext.delete(alarm)
        }
        saveContext()
    }

    // ✅ Save Changes to Core Data
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
