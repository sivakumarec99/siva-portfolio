//
//  AuthViewModel.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    private let authService = AuthService.shared

    init() {
        self.isAuthenticated = authService.isUserLoggedIn()
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.signUp(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isAuthenticated = true
                case .failure:
                    self.isAuthenticated = false
                }
                completion(result)
            }
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.signIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isAuthenticated = true
                case .failure:
                    self.isAuthenticated = false
                }
                completion(result)
            }
        }
    }

    // MARK: - Sign Out
    func signOut() {
        authService.signOut { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isAuthenticated = false
                case .failure(let error):
                    print("Error signing out: \(error.localizedDescription)")
                }
            }
        }
    }
}
