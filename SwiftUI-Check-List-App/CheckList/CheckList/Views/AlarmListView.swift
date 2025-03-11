//
//  AlarmListView.swift
//  CheckList
//
//  Created by JIDTP1408 on 11/03/25.
//

import Foundation
import SwiftUI

struct AlarmListView: View {
    @ObservedObject var alarmManager: AlarmManager // ✅ Ensure it listens for updates

    var body: some View {
        List {
            
            ForEach(alarmManager.alarms) { alarm in
                HStack {
                    Text(alarm.time, style: .time)
                        .font(.headline)
                    Spacer()
                    Text(alarm.label)
                        .foregroundColor(.gray)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { alarmManager.deleteAlarm(at: $0) }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}
