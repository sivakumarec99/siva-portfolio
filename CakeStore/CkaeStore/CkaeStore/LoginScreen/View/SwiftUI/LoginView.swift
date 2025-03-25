//
//  LoginView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import SwiftUI

struct LoginView: View {
    var onLoginSuccess: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Image(systemName: "cup.and.saucer.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)

                Text("Welcome to Cake World!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                VStack(spacing: 15) {
                    SocialLoginButton(title: "Sign in with Google", color: .white, textColor: .black) {
                        loginSuccess()
                    }

                    SocialLoginButton(title: "Sign in with Facebook", color: .blue, textColor: .white) {
                        loginSuccess()
                    }

                    SocialLoginButton(title: "Sign in with Apple", color: .black, textColor: .white) {
                        loginSuccess()
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }
    
    /// ✅ Handles login success
    private func loginSuccess() {
        print("✅ Login successful, dismissing login screen...")
        onLoginSuccess()  // ✅ Notifies ViewController
        presentationMode.wrappedValue.dismiss() // ✅ Dismiss login screen
    }
}
// ✅ Reusable Social Login Button
struct SocialLoginButton: View {
    let title: String
    let color: Color
    let textColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: 280, height: 50)
                .background(color)
                .foregroundColor(textColor)
                .font(.headline)
                .cornerRadius(12)
                .shadow(radius: 4)
        }
    }
}

