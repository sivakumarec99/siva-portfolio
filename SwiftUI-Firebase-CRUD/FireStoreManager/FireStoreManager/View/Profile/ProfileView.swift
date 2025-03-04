//
//  ProfileView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
//            if let user = authViewModel.user {
//                ScrollView {
//                    VStack(spacing: 20) {
//                        // 🔹 Profile Header with Background
//                        ZStack {
//                            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
//                                           startPoint: .topLeading,
//                                           endPoint: .bottomTrailing)
//                                .frame(height: 220)
//                                .cornerRadius(20)
//                                .shadow(radius: 5)
//                            
//                            VStack {
//                                if let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
//                                    KFImage(url)
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 100, height: 100)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
//                                        .shadow(radius: 5)
//                                } else {
//                                    Image(systemName: "person.crop.circle.fill")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 100, height: 100)
//                                        .foregroundColor(.white)
//                                }
//                                
//                                Text(user.fullName)
//                                    .font(.title)
//                                    .bold()
//                                    .foregroundColor(.white)
//                                
//                                Text("@\(user.username)")
//                                    .font(.subheadline)
//                                    .foregroundColor(.white.opacity(0.8))
//                            }
//                            .padding(.top, 60)
//                        }
//                        .padding(.horizontal)
//
//                        // 🔹 User Details Section
//                        VStack(alignment: .leading, spacing: 10) {
//                            DetailRow(icon: "envelope.fill", text: user.email)
//                            if let phone = user.phoneNumber {
//                                DetailRow(icon: "phone.fill", text: phone)
//                            }
//                            if let address = user.address {
//                                DetailRow(icon: "location.fill", text: address)
//                            }
//                            if let dob = user.dob {
//                                DetailRow(icon: "calendar", text: "DOB: \(dob)")
//                            }
//                            DetailRow(icon: "person.fill", text: "Role: \(user.role)")
//                            DetailRow(icon: "clock", text: "Joined: \(formattedDate(user.createdAt))")
//                            
//                            if user.isVerifiedSeller {
//                                DetailRow(icon: "checkmark.seal.fill", text: "Verified Seller ✅")
//                                    .foregroundColor(.green)
//                            }
//                        }
//                        .padding(.horizontal)
//                        .padding(.top, 10)
//                        
//                        // 🔹 Action Buttons
//                        VStack(spacing: 15) {
//                            Button(action: {
//                                // Edit Profile Action
//                            }) {
//                                ProfileButton(title: "Edit Profile", color: .blue)
//                            }
//                            
//                            Button(action: {
//                                // Navigate to Settings
//                            }) {
//                                ProfileButton(title: "Settings", color: .gray)
//                            }
//                            
//                            Button(action: {
//                                authViewModel.signOut()
//                            }) {
//                                ProfileButton(title: "Log Out", color: .red)
//                            }
//                        }
//                        .padding(.top, 20)
//                    }
//                }
//            } else {
//                ProgressView()
//            }
        }
        .onAppear {
//            authViewModel.fetchUserProfile()
        }
    }
    
    // 🔹 Reusable Detail Row Component
    private func DetailRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 25)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }

    // 🔹 Reusable Button Component
    private func ProfileButton(title: String, color: Color) -> some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
    
    // 🔹 Date Formatting
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
