//
//  UserProfile.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 03/03/25.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?  // Firebase UID

    var fullName: String
    var username: String
    var email: String
    var profileImageUrl: String?
    var phoneNumber: String?
    var address: String?
    var dob: String?  // Store as "YYYY-MM-DD"
    var gender: String?
    var role: String  // "Customer", "Seller", "Admin", etc.
    var createdAt: Date
    var lastActiveAt: Date
    var isVerifiedSeller: Bool
    var orderHistory: [String] // Array of order IDs
    var wishlist: [String] // Array of product IDs
    var socialLinks: [String: String]? // Facebook, Twitter, etc.
}
