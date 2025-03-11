//
//  ProfileView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import SwiftUI
import Kingfisher
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showingSocialLinks = false
    @State private var selectedTab = 0
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                if authViewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading profile...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else if let user = authViewModel.user {
                    VStack(spacing: 20) {
                        // 🔹 Profile Header with Background
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing)
                            .frame(height: 250)
                            .edgesIgnoringSafeArea(.top)
                            
                            VStack(spacing: 15) {
                                if let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        .shadow(radius: 5)
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .foregroundColor(.white)
                                }
                                
                                VStack(spacing: 5) {
                                    Text(user.fullName ?? "New User")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    if let username = user.username {
                                        Text("@\(username)")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    
                                    if user.isVerifiedSeller {
                                        Label("Verified Seller", systemImage: "checkmark.seal.fill")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.green.opacity(0.3))
                                            .cornerRadius(15)
                                    }
                                }
                            }
                            .padding(.top, 30)
                        }
                        
                        // 🔹 Segmented Control
                        Picker("View", selection: $selectedTab) {
                            Text("Profile").tag(0)
                            Text("Activity").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        if selectedTab == 0 {
                            // 🔹 Profile Information
                            VStack(spacing: 20) {
                                InfoSection(title: "Contact Information") {
                                    DetailRow(icon: "envelope.fill", text: user.email)
                                    if let phone = user.phoneNumber {
                                        DetailRow(icon: "phone.fill", text: phone)
                                    }
                                    if let address = user.address {
                                        DetailRow(icon: "location.fill", text: address)
                                    }
                                }
                                
                                InfoSection(title: "Personal Information") {
                                    if let dob = user.dob {
                                        DetailRow(icon: "calendar", text: "Born \(dob)")
                                    }
                                    if let gender = user.gender {
                                        DetailRow(icon: "person.fill", text: gender)
                                    }
                                    DetailRow(icon: "person.text.rectangle.fill", text: "Role: \(user.role)")
                                }
                                
                                if !user.socialLinks.isEmpty {
                                    InfoSection(title: "Social Links") {
                                        ForEach(Array(user.socialLinks.keys.sorted()), id: \.self) { platform in
                                            if let link = user.socialLinks[platform] {
                                                DetailRow(icon: socialIcon(for: platform), text: platform)
                                                    .onTapGesture {
                                                        if let url = URL(string: link) {
                                                            UIApplication.shared.open(url)
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            // 🔹 Activity Tab
                            VStack(spacing: 20) {
                                InfoSection(title: "Recent Activity") {
                                    if let lastActive = user.lastActiveAt {
                                        DetailRow(icon: "clock.fill", text: "Last active: \(formattedDate(lastActive))")
                                    }
                                    DetailRow(icon: "calendar.badge.clock", text: "Joined: \(formattedDate(user.createdAt))")
                                }
                                
                                if !user.orderHistory.isEmpty {
                                    InfoSection(title: "Order History") {
                                        Text("\(user.orderHistory.count) orders placed")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if !user.wishlist.isEmpty {
                                    InfoSection(title: "Wishlist") {
                                        Text("\(user.wishlist.count) items saved")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 🔹 Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                // Edit Profile Action
                            }) {
                                ProfileButton(title: "Edit Profile", color: .blue, icon: "pencil")
                            }
                            
                            Button(action: {
                                // Navigate to Settings
                            }) {
                                ProfileButton(title: "Settings", color: .gray, icon: "gear")
                            }
                            
                            Button(action: {
                                Task {
                                    do {
                                        try await authViewModel.signOut()
                                    } catch {
                                        showError = true
                                        errorMessage = error.localizedDescription
                                    }
                                }
                            }) {
                                ProfileButton(title: "Log Out", color: .red, icon: "arrow.right.square")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Could not load profile")
                            .font(.headline)
                        
                        if let error = authViewModel.error {
                            Text(error.localizedDescription)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                        
                        Button("Try Again") {
                            Task {
                                try? await authViewModel.fetchUserProfile()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showError) {
                Button("OK") { showError = false }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            Task {
                try? await authViewModel.fetchUserProfile()
            }
        }
    }
    
    // 🔹 Helper Functions
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func socialIcon(for platform: String) -> String {
        switch platform.lowercased() {
        case "facebook": return "f.circle.fill"
        case "twitter": return "t.circle.fill"
        case "instagram": return "camera.circle.fill"
        case "linkedin": return "l.circle.fill"
        default: return "link.circle.fill"
        }
    }
}

// 🔹 Reusable Components
private struct InfoSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

private struct DetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

private struct ProfileButton: View {
    let title: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}
