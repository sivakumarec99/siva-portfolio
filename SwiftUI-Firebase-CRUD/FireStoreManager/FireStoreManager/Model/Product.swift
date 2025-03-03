//
//  Product.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import Foundation

struct Product: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var imageUrls: [String]  // Multiple images
    var threeDModelUrl: String?  // Link to a 3D model file (GLTF, USDZ)
    var view360Urls: [String]?  // List of images for a 360-degree view
    var category: String
    var stock: Int
    var rating: Double
    var reviews: [Review]
    var ratingBreakdown: RatingBreakdown
    var discount: Double
    var createdAt: Date
    var seller: SellerDetails  // Seller information
    var specifications: [String: String] // Key-value pairs (e.g., "Material": "Cotton")
    var variations: [ProductVariation] // Different sizes/colors
    var isFeatured: Bool  // Highlighted products
    var isAvailable: Bool  // Whether the product is active
    var deliveryDetails: DeliveryDetails  // Estimated delivery, shipping costs
    var similarProducts: [SimilarProduct]  // Recommended products
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
