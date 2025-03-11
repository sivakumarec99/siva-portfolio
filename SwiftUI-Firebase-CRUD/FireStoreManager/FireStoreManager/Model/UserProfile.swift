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
    
    // Required fields
    var email: String
    var createdAt: Date
    
    // Optional user details
    var fullName: String?
    var username: String?
    var profileImageUrl: String?
    var phoneNumber: String?
    var address: String?
    var dob: String?  // Store as "YYYY-MM-DD"
    var gender: String?
    var role: String = "user"  // Default role
    var lastActiveAt: Date?
    var isVerifiedSeller: Bool = false
    
    // Collections
    var orderHistory: [String] = []  // Array of order IDs
    var wishlist: [String] = []  // Array of product IDs
    var socialLinks: [String: String] = [:]  // Facebook, Twitter, etc.
    
    // Custom coding keys to handle Firestore timestamp
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case createdAt
        case fullName
        case username
        case profileImageUrl
        case phoneNumber
        case address
        case dob
        case gender
        case role
        case lastActiveAt
        case isVerifiedSeller
        case orderHistory
        case wishlist
        case socialLinks
    }
    
    // Custom decoder to handle Firestore timestamp
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        id = try container.decodeIfPresent(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        
        // Handle Timestamp for createdAt
        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = Date()
        }
        
        // Optional fields
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        dob = try container.decodeIfPresent(String.self, forKey: .dob)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        role = try container.decodeIfPresent(String.self, forKey: .role) ?? "user"
        
        // Handle Timestamp for lastActiveAt
        if let timestamp = try? container.decode(Timestamp.self, forKey: .lastActiveAt) {
            lastActiveAt = timestamp.dateValue()
        } else {
            lastActiveAt = nil
        }
        
        isVerifiedSeller = try container.decodeIfPresent(Bool.self, forKey: .isVerifiedSeller) ?? false
        orderHistory = try container.decodeIfPresent([String].self, forKey: .orderHistory) ?? []
        wishlist = try container.decodeIfPresent([String].self, forKey: .wishlist) ?? []
        socialLinks = try container.decodeIfPresent([String: String].self, forKey: .socialLinks) ?? [:]
    }
    
    // Custom encoder to handle Firestore timestamp
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
        
        // Optional fields
        try container.encodeIfPresent(fullName, forKey: .fullName)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(profileImageUrl, forKey: .profileImageUrl)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(dob, forKey: .dob)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encode(role, forKey: .role)
        
        if let lastActive = lastActiveAt {
            try container.encode(Timestamp(date: lastActive), forKey: .lastActiveAt)
        }
        
        try container.encode(isVerifiedSeller, forKey: .isVerifiedSeller)
        try container.encode(orderHistory, forKey: .orderHistory)
        try container.encode(wishlist, forKey: .wishlist)
        try container.encode(socialLinks, forKey: .socialLinks)
    }
    
    // Initializer for creating new user profiles
    init(id: String, email: String, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
    }
}
