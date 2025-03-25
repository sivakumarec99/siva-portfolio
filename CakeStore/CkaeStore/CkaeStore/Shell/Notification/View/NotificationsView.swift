//
//  NotificationsView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import Foundation
import SwiftUI

struct NotificationsView: View {
    let notifications = [
        "📢 Your cake order was delivered!",
        "🎉 A new order has been placed!",
        "🔔 Your revenue has increased!",
        "⭐ New customer review received!"
    ]

    var body: some View {
        VStack {
            Text("Notifications")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(notifications, id: \.self) { notification in
                        Text(notification)
                            .font(.headline)
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(10)
                            .transition(.opacity)
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}
