//
//  ProfileView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile").font(.largeTitle).bold()

            Button("Sign Out") {
                authViewModel.signOut()
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(.red)
        }
        .padding()
    }
}
