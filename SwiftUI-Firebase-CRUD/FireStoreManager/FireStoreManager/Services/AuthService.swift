//
//  AuthService.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import Foundation
import FirebaseAuth

class AuthService {
    static let shared = AuthService()

    // MARK: - Sign Up
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    // MARK: - Sign Out
    func signOut() async throws {
        try Auth.auth().signOut()
    }

    // MARK: - Check Authentication Status
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
