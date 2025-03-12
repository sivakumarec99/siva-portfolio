import SwiftUI

struct AddAlarmView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var alarmManager: AlarmManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var selectedDays: Set<String> = []
    @State private var alarmLabel = ""
    @State private var selectedSound = "Default"
    @State private var vibrationEnabled = true
    @State private var snoozeTime = 5
    @State private var selectedBackground = "defaultImage"
    @State private var showDatePicker = false
    @State private var isEnabled = true

    let availableSounds = ["Default", "Chime", "Radar", "Bells", "Classic"]
    let snoozeOptions = [5, 10, 15]
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var existingAlarm: AlarmEntity?

    init(alarmManager: AlarmManager, existingAlarm: AlarmEntity? = nil) {
        self.alarmManager = alarmManager
        self.existingAlarm = existingAlarm
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 🌈 Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // ⏰ Time Picker
                        TimePickerView(selectedTime: $selectedTime)

                        // 📆 Date & Repeat Days
                        DateRepeatView(selectedDate: $selectedDate, selectedDays: $selectedDays, showDatePicker: $showDatePicker, weekdays: weekdays)

                        // 🏷 Alarm Name
                        CustomTextField(title: "Alarm Name", text: $alarmLabel)

                        // 🎵 Sound Picker
                        CustomPicker(title: "Alarm Sound", selection: $selectedSound, options: availableSounds)

                        // 📳 Vibration Toggle
                        CustomToggle(title: "Enable Vibration", isOn: $vibrationEnabled)

                        // ⏲ Snooze Duration Picker
                        CustomPicker(title: "Snooze Duration", selection: $snoozeTime, options: snoozeOptions)

                        // 🎨 Background Picker
                        AlarmBackgroundPickerView(selectedBackground: $selectedBackground)

                        // ✅ Save Button
                        Button(action: saveAlarm) {
                            Text("Save Alarm")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle(existingAlarm == nil ? "New Alarm" : "Edit Alarm")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear(perform: loadExistingAlarm)
        }
    }

    // ✅ Load existing alarm details
    private func loadExistingAlarm() {
        if let alarm = existingAlarm {
            selectedTime = alarm.time ?? Date()
            alarmLabel = alarm.name ?? ""
            isEnabled = alarm.isEnabled
            selectedSound = alarm.sound ?? "Default"
            vibrationEnabled = alarm.isEnabled
            snoozeTime = Int(alarm.snoozeDuration)
            selectedDays = Set(alarm.repeatDays?.components(separatedBy: ",") ?? [])
            selectedBackground = alarm.background ?? "defaultImage"
        }
    }

    // ✅ Save or update alarm
    private func saveAlarm() {
        let calendar = Calendar.current
        let selectedDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: selectedTime),
            minute: calendar.component(.minute, from: selectedTime),
            second: 0,
            of: selectedDate
        ) ?? Date()

        if selectedDateTime < Date() {
            print("❌ Cannot set an alarm in the past")
            return
        }

        if let alarm = existingAlarm {
            alarmManager.updateAlarm(
                alarm,
                time: selectedDateTime,
                name: alarmLabel,
                sound: selectedSound,
                snoozeDuration: snoozeTime,
                repeatDays: selectedDays,
                background: selectedBackground,
                isEnabled: isEnabled
            )
        } else {
            alarmManager.addAlarm(
                time: selectedDateTime,
                name: alarmLabel,
                sound: selectedSound,
                snoozeDuration: snoozeTime,
                repeatDays: selectedDays,
                background: selectedBackground,
                isEnabled: isEnabled
            )
        }

        dismiss()
    }
}

// ✅ Separate Time Picker View
struct TimePickerView: View {
    @Binding var selectedTime: Date

    var body: some View {
        VStack {
            Text("Set Time")
                .font(.headline)
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .frame(height: 100)
                .clipped()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
    }
}

// ✅ Date & Repeat Selection
struct DateRepeatView: View {
    @Binding var selectedDate: Date
    @Binding var selectedDays: Set<String>
    @Binding var showDatePicker: Bool
    let weekdays: [String]

    var body: some View {
        VStack {
            HStack {
                Text("Repeat Days")
                    .font(.headline)
                Spacer()
                Button(action: { showDatePicker.toggle() }) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .frame(width: 40, height: 40)
                        .background(selectedDays.contains(day) ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .onTapGesture {
                            if selectedDays.contains(day) {
                                selectedDays.remove(day)
                            } else {
                                selectedDays.insert(day)
                            }
                        }
                }
            }

            if showDatePicker {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
    }
}

// ✅ Reusable Components
struct CustomTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            TextField(title, text: $text)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
        }
    }
}

struct CustomPicker<T: Hashable>: View {
    var title: String
    @Binding var selection: T
    var options: [T]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text("\(option)").tag(option)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

struct CustomToggle: View {
    var title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(title, isOn: $isOn)
    }
}
