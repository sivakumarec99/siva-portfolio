//
//  EmptyStateView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 10/03/25.
//

import SwiftUI

struct EmptyStateView: View {
    let message: String
    let systemImage: String
    let tint: Color
    
    init(
        message: String,
        systemImage: String = "cart.fill.badge.plus",
        tint: Color = .gray
    ) {
        self.message = message
        self.systemImage = systemImage
        self.tint = tint
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(tint)
            
            Text(message)
                .font(.headline)
                .foregroundColor(tint)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
