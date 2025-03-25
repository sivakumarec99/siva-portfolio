//
//  LoginManager.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class LoginManager: ObservableObject {
    @Published var user: UserModel?
    @Published var isLoading: Bool = false
    @Published var loginError: String?

    // ✅ Check if user is already logged in
    func checkUserStatus() {
        if let currentUser = Auth.auth().currentUser {
            user = UserModel(
                id: currentUser.uid,
                name: currentUser.displayName,
                email: currentUser.email,
                profileImageURL: currentUser.photoURL?.absoluteString,
                provider: currentUser.providerData.first?.providerID
            )
        }
    }

    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            loginError = "❌ Firebase not configured properly."
            return
        }

        isLoading = true

        // ✅ Get RootViewController
        guard let rootVC = getRootViewController() else {
            loginError = "❌ Unable to get RootViewController."
            isLoading = false
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { signInResult, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.loginError = "Google Login Failed: \(error.localizedDescription)"
                    return
                }

                // ✅ Fix: Access idToken & accessToken properly
                guard let user = signInResult?.user else {
                    self.loginError = "❌ Failed to retrieve Google authentication user."
                    return
                }

                let idToken = user.idToken?.tokenString ?? ""
                let accessToken = user.accessToken.tokenString

                if idToken.isEmpty {
                    self.loginError = "❌ Google authentication token is empty."
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                self.authenticateWithFirebase(credential, provider: "google.com")
            }
        }
    }

    // ✅ Firebase Authentication
    private func authenticateWithFirebase(_ credential: AuthCredential, provider: String) {
        isLoading = true
        Auth.auth().signIn(with: credential) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.loginError = "Firebase Auth Error: \(error.localizedDescription)"
                    return
                }
                if let currentUser = authResult?.user {
                    self.user = UserModel(
                        id: currentUser.uid,
                        name: currentUser.displayName,
                        email: currentUser.email,
                        profileImageURL: currentUser.photoURL?.absoluteString,
                        provider: provider
                    )
                }
            }
        }
    }

    // ✅ Log Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            loginError = "Sign Out Failed: \(error.localizedDescription)"
        }
    }

    // ✅ Get Root ViewController (Fixed)
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
}
