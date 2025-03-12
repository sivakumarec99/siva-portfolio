import SwiftUI

struct HomeView: View {
    @State private var selectedTab: MainTopic = .alarms
    @State private var showProfileDetails = false
    @State private var showNewBlockCreation = false
    @StateObject private var alarmManager = AlarmManager()
    @State private var showAddAlarmView = false
    
    enum MainTopic: String, CaseIterable {
        case alarms = "Alarms"
        case checklist = "Check List"
        case notes = "Notes"
        case rememberNotes = "Remember Notes"
        
        var icon: String {
            switch self {
            case .alarms: return "alarm.fill"
            case .checklist: return "checklist"
            case .notes: return "note.text"
            case .rememberNotes: return "pin.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .alarms: return .red
            case .checklist: return .blue
            case .notes: return .green
            case .rememberNotes: return .orange
            }
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    // Profile Button
                    Button(action: { showProfileDetails = true }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.primary)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Create New Block Button
                    Button(action: { showNewBlockCreation = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                            .padding()
                    }
                   
                    Button(action: { showAddAlarmView = true }) {
                        Image(systemName: "alarm.fill") // ⏰ Alarm Icon
                            .font(.system(size: 30))
                            .foregroundColor(.primary)
                            .padding()
                    }
                    
                }
                .background(Color(UIColor.systemBackground))
                .shadow(radius: 3)
                
                // Topics Collection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(MainTopic.allCases, id: \.self) { topic in
                            TopicCard(topic: topic, isSelected: selectedTab == topic)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedTab = topic
                                    }
                                }
                        }
                    }
                    .padding()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        if selectedTab == .alarms {
                            AlarmListView()
                        } else {
                            Text("\(selectedTab.rawValue) Content")
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Content Area
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .alarms:
                            Text("Alarms Content")
                        case .checklist:
                            Text("Checklist Content")
                        case .notes:
                            Text("Notes Content")
                        case .rememberNotes:
                            Text("Remember Notes Content")
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .sheet(isPresented: $showProfileDetails) {
                ProfileDetailsView()
            }
            .sheet(isPresented: $showNewBlockCreation) {
                NewBlockView()
            }
            .sheet(isPresented: $showAddAlarmView) {
                AddAlarmView(alarmManager: alarmManager)
            }
        }
    }
}

struct TopicCard: View {
    let topic: HomeView.MainTopic
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: topic.icon)
                .font(.system(size: 24))
            Text(topic.rawValue)
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundColor(isSelected ? .white : topic.color)
        .frame(width: 100, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? topic.color : Color(UIColor.systemBackground))
                .shadow(color: topic.color.opacity(0.3), radius: 5)
        )
    }
}

struct ProfileDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Profile Details")
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct NewBlockView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Create New Block")
                .navigationTitle("New Block")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    HomeView()
}

