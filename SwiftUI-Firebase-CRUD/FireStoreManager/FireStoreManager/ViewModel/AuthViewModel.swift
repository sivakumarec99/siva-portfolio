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
    private let authService = AuthService.shared

    init() {
        self.isAuthenticated = authService.isUserLoggedIn()
        setupAuthStateListener()
        if isAuthenticated {
            Task {
                try? await fetchUserProfile()
            }
        }
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                if user != nil {
                    Task {
                        try? await self?.fetchUserProfile()
                    }
                } else {
                    self?.user = nil
                }
            }
        }
    }
    
    func fetchUserProfile() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user found"])
        }
        
        // Fetch user profile from Firestore
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            
            guard document.exists else {
                throw NSError(domain: "AuthViewModel", code: -2, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
            }
            
            let userData = try document.data(as: UserProfile.self)
            
            await MainActor.run {
                self.user = userData
            }
        } catch let firestoreError as DecodingError {
            throw NSError(domain: "AuthViewModel", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user profile: \(firestoreError.localizedDescription)"])
        } catch {
            throw NSError(domain: "AuthViewModel", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user profile: \(error.localizedDescription)"])
        }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String) async throws {
        do {
            try await authService.signUp(email: email, password: password)
            await MainActor.run {
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.isAuthenticated = false
            }
            throw error
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        do {
            try await authService.signIn(email: email, password: password)
            await MainActor.run {
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.isAuthenticated = false
            }
            throw error
        }
    }

    // MARK: - Sign Out
    func signOut() async throws {
        do {
            try await authService.signOut()
            await MainActor.run {
                self.isAuthenticated = false
                self.user = nil
            }
        } catch {
            throw NSError(domain: "AuthViewModel", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to sign out: \(error.localizedDescription)"])
        }
    }
}
