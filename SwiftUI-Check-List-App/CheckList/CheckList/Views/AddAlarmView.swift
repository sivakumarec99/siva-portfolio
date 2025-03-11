//
//  AddAlarmView.swift
//  CheckList
//
//  Created by JIDTP1408 on 11/03/25.
//

import Foundation
import SwiftUI

struct AddAlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var alarmManager: AlarmManager

    @State private var selectedTime = Date()
    @State private var label = ""

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()

                TextField("Alarm Label", text: $label)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Save Alarm") {
                    alarmManager.addAlarm(time: selectedTime, label: label)
                    dismiss()
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("New Alarm")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
