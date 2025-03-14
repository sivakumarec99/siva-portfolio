//
//  ProfileEditView.swift
//  CheckList
//
//  Created by JIDTP1408 on 14/03/25.
//

import Foundation
import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var newName: String = ""
    @State private var newImage: UIImage?
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            VStack {
                Button(action: { showImagePicker = true }) {
                    if let newImage = newImage {
                        Image(uiImage: newImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    } else if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                            .shadow(radius: 5)
                    }
                }

                TextField("Enter new name", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Save Changes") {
                    viewModel.updateUserProfile(newDisplayName: newName, newImage: newImage)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle("Edit Profile")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $newImage, allowsEditing: true, sourceType: .photoLibrary)
            }
        }
    }
}
