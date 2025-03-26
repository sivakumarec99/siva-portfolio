//
//  EditProfileView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 26/03/25.
//

import Foundation
import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var chef: ChefProfile  // ✅ Make Profile Editable

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Details")) {
                    TextField("Full Name", text: $chef.fullName)
                    TextField("Bio", text: $chef.bio ?? "")
                }
                
                Section(header: Text("Contact Info")) {
                    TextField("Phone Number", text: $chef.phoneNumber)
                    TextField("Email", text: $chef.email ?? "")
                }
                
                Button("Save Changes") {
                    try? chef.save()  // ✅ Save to SwiftData
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
