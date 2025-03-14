//
//  ProfileViewModel.swift
//  CheckList
//
//  Created by JIDTP1408 on 14/03/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    @Published var user: User?  // Stores logged-in user details
    @Published var profileImage: UIImage?  // Stores user's profile image
    @Published var isLoading = false  // Tracks loading state
    @Published var errorMessage: String?  // Stores error messages
    @Published var shouldNavigateToLogin = false

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

   
    init() {
        checkUserStatus()
    }
    
    // ✅ Check Firebase Authentication & Load Profile Data
    func checkUserStatus() {
        if let firebaseUser = Auth.auth().currentUser {
            self.user = User(
                id: firebaseUser.uid,
                email: firebaseUser.email ?? "",
                displayName: firebaseUser.displayName,
                isEmailVerified: firebaseUser.isEmailVerified
            )
            fetchUserDetails(userID: firebaseUser.uid)
        } else {
            self.user = nil
        }
    }
    
    // ✅ Fetch User Details from Firestore
    func fetchUserDetails(userID: String) {
        isLoading = true
        db.collection("users").document(userID).getDocument { document, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let document = document, document.exists, let data = document.data() {
                    self.user = User(documentData: data)
                    self.loadProfileImage(urlString: self.user?.profileImageUrl)
                } else {
                    self.errorMessage = "Failed to fetch user details."
                    print("Firestore Error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

    // ✅ Load Profile Image from Firebase Storage
    func loadProfileImage(urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self.profileImage = image
                } else {
                    print("Failed to load profile image: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }.resume()
    }

    // ✅ Update User Profile (Name & Profile Picture)
    func updateUserProfile(newDisplayName: String?, newImage: UIImage?) {
        guard let userID = user?.id else { return }
        isLoading = true
        
        var updatedData: [String: Any] = [:]
        if let newDisplayName = newDisplayName {
            updatedData["displayName"] = newDisplayName
        }
        
        if let newImage = newImage {
            uploadProfileImage(newImage) { imageUrl in
                if let imageUrl = imageUrl {
                    updatedData["profileImageUrl"] = imageUrl
                }
                self.saveProfileUpdates(userID: userID, data: updatedData)
            }
        } else {
            saveProfileUpdates(userID: userID, data: updatedData)
        }
    }

    // ✅ Upload Profile Image to Firebase Storage
    private func uploadProfileImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let storageRef = storage.reference().child("profile_images/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Image upload error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to retrieve image URL: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }

    // ✅ Save Profile Updates to Firestore
    private func saveProfileUpdates(userID: String, data: [String: Any]) {
        guard !data.isEmpty else { return }
        
        db.collection("users").document(userID).updateData(data) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
                } else {
                    self.checkUserStatus()  // Reload user details
                }
            }
        }
    }

    // ✅ Logout User
    func logout() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
    func navigateToLogin() {
        shouldNavigateToLogin = true
    }
}
