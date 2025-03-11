//
//  AuthViewModel.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: UserProfile?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let authService = AuthService.shared
    private let db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        self.isAuthenticated = authService.isUserLoggedIn()
        setupAuthStateListener()
        if isAuthenticated {
            Task {
                try? await fetchUserProfile()
            }
        }
    }
    
    deinit {
        // Remove auth state listener when ViewModel is deallocated
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.isAuthenticated = user != nil
                if user != nil {
                    do {
                        try await self.fetchUserProfile()
                    } catch {
                        self.error = error
                        self.user = nil
                    }
                } else {
                    self.user = nil
                }
            }
        }
    }
    
    @MainActor
    func fetchUserProfile() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AuthError.noAuthenticatedUser
        }
        
        isLoading = true
        error = nil
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            
            guard document.exists else {
                // If user document doesn't exist, create it with basic info
                let newUser = UserProfile(
                    id: userId,
                    email: Auth.auth().currentUser?.email ?? "",
                    createdAt: Date()
                )
                try await createUserProfile(newUser)
                self.user = newUser
                return
            }
            
            self.user = try document.data(as: UserProfile.self)
            
        } catch let firestoreError as DecodingError {
            throw AuthError.profileDecodingError(firestoreError)
        } catch {
            throw AuthError.profileFetchError(error)
        }
        
        isLoading = false
    }
    
    @MainActor
    private func createUserProfile(_ profile: UserProfile) async throws {
        do {
            try await db.collection("users").document(profile.id!).setData(from: profile)
        } catch {
            throw AuthError.profileCreationError(error)
        }
    }
    
    @MainActor
    func updateUserProfile(with updates: [String: Any]) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AuthError.noAuthenticatedUser
        }
        
        isLoading = true
        error = nil
        
        do {
            try await db.collection("users").document(userId).updateData(updates)
            try await fetchUserProfile() // Refresh user data
        } catch {
            throw AuthError.profileUpdateError(error)
        }
        
        isLoading = false
    }

    // MARK: - Sign Up
    @MainActor
    func signUp(email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            try await authService.signUp(email: email, password: password)
            self.isAuthenticated = true
            
            // Create user profile after successful sign up
            if let userId = Auth.auth().currentUser?.uid {
                let newUser = UserProfile(
                    id: userId,
                    email: email,
                    createdAt: Date()
                )
                try await createUserProfile(newUser)
                self.user = newUser
            }
        } catch {
            self.isAuthenticated = false
            throw AuthError.signUpError(error)
        }
        
        isLoading = false
    }

    // MARK: - Sign In
    @MainActor
    func signIn(email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            try await authService.signIn(email: email, password: password)
            self.isAuthenticated = true
            try await fetchUserProfile()
        } catch {
            self.isAuthenticated = false
            throw AuthError.signInError(error)
        }
        
        isLoading = false
    }

    // MARK: - Sign Out
    @MainActor
    func signOut() async throws {
        isLoading = true
        error = nil
        
        do {
            try await authService.signOut()
            self.isAuthenticated = false
            self.user = nil
        } catch {
            throw AuthError.signOutError(error)
        }
        
        isLoading = false
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case noAuthenticatedUser
    case profileDecodingError(Error)
    case profileFetchError(Error)
    case profileCreationError(Error)
    case profileUpdateError(Error)
    case signUpError(Error)
    case signInError(Error)
    case signOutError(Error)
    
    var errorDescription: String? {
        switch self {
        case .noAuthenticatedUser:
            return "No authenticated user found"
        case .profileDecodingError(let error):
            return "Failed to decode user profile: \(error.localizedDescription)"
        case .profileFetchError(let error):
            return "Failed to fetch user profile: \(error.localizedDescription)"
        case .profileCreationError(let error):
            return "Failed to create user profile: \(error.localizedDescription)"
        case .profileUpdateError(let error):
            return "Failed to update user profile: \(error.localizedDescription)"
        case .signUpError(let error):
            return "Failed to sign up: \(error.localizedDescription)"
        case .signInError(let error):
            return "Failed to sign in: \(error.localizedDescription)"
        case .signOutError(let error):
            return "Failed to sign out: \(error.localizedDescription)"
        }
    }
}
