//
//  ProfileView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @State private var profileImageURL: String? = "https://via.placeholder.com/150" // Replace with actual URL
    @State private var userName: String = "John Doe"
    @State private var userDescription: String = "Expert Cake Seller & Baker"
    @State private var phoneNumber: String = "+1 234 567 890"
    @State private var email: String = "johndoe@example.com"
    @State private var address: String = "123, Baking Street, New York, USA"
    
    var body: some View {
        VStack(spacing: 20) {
            // ✅ Profile Image with URL or Default Image
            AsyncImage(url: URL(string: profileImageURL ?? "")) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "person.crop.circle.fill") // Default Image
                    .resizable()
                    .foregroundColor(.gray)
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.orange, lineWidth: 3))
            .shadow(radius: 5)
            
            // ✅ User Name & Description
            Text(userName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(userDescription)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // ✅ Contact Information
            VStack(alignment: .leading, spacing: 10) {
                ContactRow(icon: "phone.fill", text: phoneNumber)
                ContactRow(icon: "envelope.fill", text: email)
                ContactRow(icon: "map.fill", text: address)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)).shadow(radius: 2))
            
            // ✅ Edit Profile Button
            Button(action: {
                print("Edit Profile Tapped")
            }) {
                Text("Edit Profile")
                    .frame(width: 200, height: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ContactRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}
