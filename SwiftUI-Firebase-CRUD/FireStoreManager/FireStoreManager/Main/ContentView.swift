//
//  ContentView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import SwiftUI
import CoreData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isAuthenticated {
            HomeTabView()
        } else {
            SignInView()
        }
    }
}
