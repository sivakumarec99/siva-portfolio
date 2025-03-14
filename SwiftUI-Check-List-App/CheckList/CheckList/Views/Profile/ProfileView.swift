//
//  ProfileView.swift
//  CheckList
//
//  Created by JIDTP1408 on 14/03/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    @State private var isAnimating = false
    @State private var showEditSheet = false

    private let gradientColors: [Color] = [
        Color.blue.opacity(0.8),
        Color.purple.opacity(0.8),
        Color.pink.opacity(0.8)
    ]

    var body: some View {
        NavigationStack{
            ZStack {
                // 🔹 Animated Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .hueRotation(.degrees(isAnimating ? 15 : 0))
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)

                VStack {
                    if let user = viewModel.user {
                        profileContent(user: user)
                            .transition(.opacity)
                    } else {
                        notLoggedInView
                            .transition(.opacity)
                    }
                }
                .padding()
            }
            .onAppear {
                viewModel.checkUserStatus()
                isAnimating = true
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToLogin) {
                LoginView()
            }

        }
    }

    // MARK: - Profile Content View
    @ViewBuilder
    private func profileContent(user: User) -> some View {
            VStack(spacing: 16) {
                // 🔹 Profile Image
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .shadow(radius: 8)

                    if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.7), lineWidth: 2)
                            )
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(radius: 5)
                    }
                }
                .onTapGesture {
                    showEditSheet = true
                }

                // 🔹 User Details
                Text(user.displayName ?? "No Name Available")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .shadow(radius: 3)

                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                // 🔹 Buttons
                HStack(spacing: 20) {
                    Button(action: { showEditSheet = true }) {
                        Label("Edit", systemImage: "pencil")
                            .frame(width: 120, height: 44)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }

                    Button(action: viewModel.logout) {
                        Label("Sign Out", systemImage: "arrow.right.circle")
                            .frame(width: 120, height: 44)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.15))
                    .blur(radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(radius: 10)
            .padding()
            .sheet(isPresented: $showEditSheet) {
                ProfileEditView(viewModel: viewModel)
            }
           
        
    }

    // MARK: - Not Logged In View
    private var notLoggedInView: some View {
        VStack(spacing: 20) {
            Text("You're not logged in")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .shadow(radius: 3)

            Button(action: viewModel.navigateToLogin) {
                Text("Login")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.8))
                    .clipShape(Capsule())
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.15))
                .blur(radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(radius: 10)
        .padding()
    }
}
