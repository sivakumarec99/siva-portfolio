//
//  Product.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var price: Double
    var imageUrls: [String]
    var threeDModelUrl: String?
    var view360Urls: [String]?
    var category: String
    var stock: Int
    var rating: Double
    var reviews: [Review]
    var ratingBreakdown: RatingBreakdown
    var discount: Double
    var createdAt: Date
    var seller: SellerDetails
    var specifications: [String: String]
    var variations: [ProductVariation]
    var isFeatured: Bool
    var isAvailable: Bool
    var deliveryDetails: DeliveryDetails
    var similarProducts: [SimilarProduct]
    var isPinned: Bool = false
    var dealEndTime: Date? // Optional deal end time
    var isFavorite: Bool = false

    // Computed property to calculate time left for deal
    var timeLeft: TimeInterval? {
        guard let dealEndTime = dealEndTime else { return nil }
        let remainingTime = dealEndTime.timeIntervalSince(Date())
        return remainingTime > 0 ? remainingTime : nil // If time is over, return nil
    }
}

struct ProductVariation: Codable {
    var variationId: String
    var color: String?
    var size: String?
    var stock: Int
    var additionalPrice: Double
}

struct Review: Codable {
    var userId: String
    var username: String
    var comment: String
    var stars: Int
    var createdAt: Date
}

struct RatingBreakdown: Codable {
    var averageRating: Double
    var totalReviews: Int
    var fiveStar: Int
    var fourStar: Int
    var threeStar: Int
    var twoStar: Int
    var oneStar: Int
}

struct SellerDetails: Codable {
    var sellerId: String
    var sellerName: String
    var contactEmail: String
    var contactPhone: String?
    var address: String?
    var sellerRating: Double
    var verified: Bool
}
struct DeliveryDetails: Codable {
    var estimatedDelivery: Date  // ETA based on location
    var shippingCost: Double
    var deliveryStatus: DeliveryStatus
}

enum DeliveryStatus: String, Codable {
    case pending
    case shipped
    case outForDelivery
    case delivered
    case canceled
}

struct SimilarProduct: Codable {
    var id: String
    var name: String
    var price: Double
    var imageUrl: String
    var rating: Double
}
struct Specification: Codable {
    var key: String
    var value: String
}

struct Variation: Codable {
    var type: String
    var value: String
}
