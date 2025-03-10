//
//  SignUpView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    @Environment(\.scenePhase) private var scenePhase
    
    enum Field: Hashable {
        case email
        case password
        case confirmPassword
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Sign up to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form fields
                    VStack(spacing: 20) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .foregroundColor(.secondary)
                                .font(.callout)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.gray)
                                TextField("Enter your email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .disabled(isLoading)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .foregroundColor(.secondary)
                                .font(.callout)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                SecureField("Enter your password", text: $password)
                                    .textContentType(.newPassword)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.next)
                                    .disabled(isLoading)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Confirm Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .foregroundColor(.secondary)
                                .font(.callout)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                SecureField("Confirm your password", text: $confirmPassword)
                                    .textContentType(.newPassword)
                                    .focused($focusedField, equals: .confirmPassword)
                                    .submitLabel(.done)
                                    .disabled(isLoading)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error message or loading state
                    Group {
                        if isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Creating account...")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                        } else if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut, value: isLoading)
                    .animation(.easeInOut, value: errorMessage)
                    
                    // Sign Up button
                    Button(action: signUp) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .disabled(isLoading)
                    
                    // Sign In link
                    NavigationLink(destination: SignInView()) {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.secondary)
                            Text("Sign In")
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        .font(.callout)
                    }
                    .padding(.top, 10)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                // Clear sensitive data when app becomes inactive
                if !isLoading {
                    password = ""
                    confirmPassword = ""
                    errorMessage = nil
                }
            }
        }
        .onSubmit {
            switch focusedField {
            case .email:
                focusedField = .password
            case .password:
                focusedField = .confirmPassword
            case .confirmPassword:
                signUp()
            case .none:
                break
            }
        }
    }

    private func signUp() {
        // Dismiss keyboard
        focusedField = nil
        
        // Trim whitespace from email
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation
        guard !trimmedEmail.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        // Basic email validation
        guard trimmedEmail.contains("@") && trimmedEmail.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        // Password validation
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            return
        }
        
        // Confirm password validation
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authViewModel.signUp(email: trimmedEmail, password: password)
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
