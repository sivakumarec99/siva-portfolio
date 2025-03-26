//
//  ProfileInfoView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 26/03/25.
//

import Foundation
import SwiftUI

struct ProfileInfoView: View {
    @State private var userName: String = "John Doe"
    @State private var userDescription: String = "Expert Cake Seller & Baker"
    @State private var phoneNumber: String = "+1 234 567 890"
    @State private var email: String = "johndoe@example.com"
    @State private var profileImageURL: String = "https://via.placeholder.com/150"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Picture")) {
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.orange, lineWidth: 3))
                    .shadow(radius: 5)
                }

                Section(header: Text("Personal Info")) {
                    TextField("Full Name", text: $userName)
                    TextField("Description", text: $userDescription)
                }
                
                Section(header: Text("Contact Info")) {
                    TextField("Phone Number", text: $phoneNumber)
                    TextField("Email", text: $email)
                }
                
                Button(action: {
                    print("Profile Updated")
                }) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
        }
    }
}
