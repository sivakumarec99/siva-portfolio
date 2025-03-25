//
//  ProfileView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundColor(.orange)

            Text("Seller Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button("Edit Profile") {
                print("Edit Profile Tapped")
            }
            .frame(width: 200, height: 50)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
