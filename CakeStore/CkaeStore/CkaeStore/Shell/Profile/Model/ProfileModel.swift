//
//  ProfileModel.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 26/03/25.
//

import Foundation
import SwiftUI

class ChefProfile: ObservableObject, Codable {
    @Published var id: String
    @Published var fullName: String
    @Published var email: String?
    @Published var phoneNumber: String
    @Published var profileImageURL: String?
    @Published var bio: String?
    @Published var experience: Int
    @Published var specialtyCuisines: [String]
    @Published var certifications: [Certification]
    @Published var rating: Double
    @Published var totalReviews: Int
    @Published var socialMediaLinks: [SocialMediaLink]
    @Published var availability: Availability
    @Published var createdAt: Date
    @Published var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, fullName, email, phoneNumber, profileImageURL, bio, experience, specialtyCuisines
        case certifications, rating, totalReviews, socialMediaLinks, availability, createdAt, updatedAt
    }

    // ✅ Custom `Decodable` Implementation
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fullName = try container.decode(String.self, forKey: .fullName)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        experience = try container.decode(Int.self, forKey: .experience)
        specialtyCuisines = try container.decode([String].self, forKey: .specialtyCuisines)
        certifications = try container.decode([Certification].self, forKey: .certifications)
        rating = try container.decode(Double.self, forKey: .rating)
        totalReviews = try container.decode(Int.self, forKey: .totalReviews)
        socialMediaLinks = try container.decode([SocialMediaLink].self, forKey: .socialMediaLinks)
        availability = try container.decode(Availability.self, forKey: .availability)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    // ✅ Custom `Encodable` Implementation
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fullName, forKey: .fullName)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(profileImageURL, forKey: .profileImageURL)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encode(experience, forKey: .experience)
        try container.encode(specialtyCuisines, forKey: .specialtyCuisines)
        try container.encode(certifications, forKey: .certifications)
        try container.encode(rating, forKey: .rating)
        try container.encode(totalReviews, forKey: .totalReviews)
        try container.encode(socialMediaLinks, forKey: .socialMediaLinks)
        try container.encode(availability, forKey: .availability)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }

    // ✅ Initializer
    init(
        id: String = UUID().uuidString,
        fullName: String,
        email: String?,
        phoneNumber: String,
        profileImageURL: String?,
        bio: String?,
        experience: Int,
        specialtyCuisines: [String],
        certifications: [Certification],
        rating: Double,
        totalReviews: Int,
        socialMediaLinks: [SocialMediaLink],
        availability: Availability,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        self.bio = bio
        self.experience = experience
        self.specialtyCuisines = specialtyCuisines
        self.certifications = certifications
        self.rating = rating
        self.totalReviews = totalReviews
        self.socialMediaLinks = socialMediaLinks
        self.availability = availability
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct Availability: Codable {
    var isAvailable: Bool               // Is the chef currently available?
    var workingDays: [String]           // Days available (e.g., ["Monday", "Wednesday"])
    var startTime: String               // Start time (e.g., "09:00 AM")
    var endTime: String                 // End time (e.g., "05:00 PM")
    var availableTimeSlots: [TimeSlot]  // Available time slots per day
}

struct TimeSlot: Codable {
    var startTime: String  // Start time (e.g., "10:00 AM")
    var endTime: String    // End time (e.g., "2:00 PM")
}

struct Certification: Codable, Identifiable {
    var id: String         // Unique ID
    var name: String       // Certification name (e.g., "Culinary Arts Diploma")
    var issuedBy: String   // Issuing authority (e.g., "Le Cordon Bleu")
    var issueDate: Date    // Date of certification
    var expiryDate: Date?  // Expiry date (if applicable)
    var certificateURL: String? // Link to digital certificate
}
struct SocialMediaLink: Codable ,Identifiable{
    var id: UUID
    var platform: String  // Platform name (e.g., "Instagram", "Facebook")
    var url: String       // Profile URL
}
struct WorkLocation: Codable {
    var address: String         // Full address
    var city: String            // City name
    var state: String           // State
    var country: String         // Country
    var zipCode: String         // Postal code
    var latitude: Double?       // GPS latitude
    var longitude: Double?      // GPS longitude
}
struct Pricing: Codable {
    var hourlyRate: Double   // Price per hour ($)
    var perDishRate: Double? // Price per dish (optional)
    var currency: String     // Currency (e.g., "USD", "EUR")
}
struct Review: Identifiable, Codable {
    let id: String           // Unique review ID
    var userId: String       // Reviewer’s ID
    var chefId: String       // Chef’s ID
    var rating: Double       // Rating (0-5)
    var reviewText: String?  // Optional review text
    var createdAt: Date      // Review date
}
struct ChefService: Codable {
    var id: String            // Unique ID
    var name: String          // Service name (e.g., "Private Dinner", "Cooking Class")
    var description: String?  // Description of the service
    var price: Double         // Service cost
}
struct Order: Identifiable, Codable {
    let id: String           // Order ID
    var chefId: String       // Chef ID
    var customerId: String   // Customer ID
    var serviceId: String    // Booked service ID
    var status: String       // Order status (Pending, Confirmed, Completed, Canceled)
    var orderDate: Date      // Date of order
    var totalAmount: Double  // Total price
    var paymentStatus: String // Payment status (Paid, Pending)
}
struct Payment: Codable {
    var id: String         // Payment ID
    var orderId: String    // Related order ID
    var customerId: String // Customer ID
    var chefId: String     // Chef ID
    var amount: Double     // Transaction amount
    var paymentMethod: String // Payment type (Credit Card, PayPal)
    var status: String     // Payment status (Paid, Failed, Pending)
    var transactionDate: Date // Date of transaction
}
