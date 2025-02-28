//
//  FireStoreManagerApp.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
@main
struct FireStoreManagerApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure() // Ensure Firebase is initialized
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel) // Inject AuthViewModel
        }
    }
    
}
