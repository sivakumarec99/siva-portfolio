//
//  CheckListApp.swift
//  CheckList
//
//  Created by JIDTP1408 on 11/03/25.
//

import SwiftUI
import FirebaseCore

@main
struct CheckListApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Core Data persistence controller
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
