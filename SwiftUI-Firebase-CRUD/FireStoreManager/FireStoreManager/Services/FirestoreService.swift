//
//  FirestoreService.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//
import FirebaseFirestore
import FirebaseStorage

struct FirestoreService {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - Create Product
    func addProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        let data: [String: Any] = [
            "id": product.id,
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageUrls": product.imageUrls,
            "threeDModelUrl": product.threeDModelUrl ?? "",
            "view360Urls": product.view360Urls ?? [],
            "category": product.category,
            "stock": product.stock,
            "rating": product.rating,
            "reviews": product.reviews.map { [
                "userId": $0.userId,
                "username": $0.username,
                "comment": $0.comment,
                "stars": $0.stars,
                "createdAt": $0.createdAt
            ]},
            "ratingBreakdown": [
                "averageRating": product.ratingBreakdown.averageRating,
                "totalReviews": product.ratingBreakdown.totalReviews,
                "fiveStar": product.ratingBreakdown.fiveStar,
                "fourStar": product.ratingBreakdown.fourStar,
                "threeStar": product.ratingBreakdown.threeStar,
                "twoStar": product.ratingBreakdown.twoStar,
                "oneStar": product.ratingBreakdown.oneStar
            ],
            "discount": product.discount,
            "createdAt": product.createdAt,
            "seller": [
                "sellerId": product.seller.sellerId,
                "sellerName": product.seller.sellerName,
                "contactEmail": product.seller.contactEmail,
                "contactPhone": product.seller.contactPhone ?? "",
                "address": product.seller.address ?? "",
                "sellerRating": product.seller.sellerRating,
                "verified": product.seller.verified
            ],
            "specifications": product.specifications,
            "variations": product.variations.map { [
                "variationId": $0.variationId,
                "color": $0.color ?? "",
                "size": $0.size ?? "",
                "stock": $0.stock,
                "additionalPrice": $0.additionalPrice
            ]},
            "isFeatured": product.isFeatured,
            "isAvailable": product.isAvailable,
            "isPinned": product.isPinned,  // ✅ Added pinned status
            "isFavorite": product.isFavorite,  // ✅ Added favorite status
            "deliveryDetails": [
                "estimatedDelivery": product.deliveryDetails.estimatedDelivery,
                "shippingCost": product.deliveryDetails.shippingCost,
                "deliveryStatus": product.deliveryDetails.deliveryStatus.rawValue
            ],
            "similarProducts": product.similarProducts.map { [
                "id": $0.id,
                "name": $0.name,
                "price": $0.price,
                "imageUrl": $0.imageUrl,
                "rating": $0.rating
            ]}
        ]
        
        db.collection("products").document(product.id!).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Read Products (Real-time Listener)
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let products = snapshot.documents.compactMap { document -> Product? in
                    let data = document.data()
                    
                    guard let name = data["name"] as? String,
                          let description = data["description"] as? String,
                          let price = data["price"] as? Double,
                          let createdAt = data["createdAt"] as? Timestamp,
                          let category = data["category"] as? String,
                          let stock = data["stock"] as? Int,
                          let rating = data["rating"] as? Double,
                          let discount = data["discount"] as? Double,
                          let sellerData = data["seller"] as? [String: Any],
                          let ratingBreakdownData = data["ratingBreakdown"] as? [String: Any],
                          let deliveryData = data["deliveryDetails"] as? [String: Any] else { return nil }

                    let imageUrls = data["imageUrls"] as? [String] ?? []
                    let threeDModelUrl = data["threeDModelUrl"] as? String
                    let view360Urls = data["view360Urls"] as? [String] ?? []
                    
                    let reviewsData = data["reviews"] as? [[String: Any]] ?? []
                    let reviews: [Review] = reviewsData.compactMap { reviewDict in
                        guard let userId = reviewDict["userId"] as? String,
                              let username = reviewDict["username"] as? String,
                              let comment = reviewDict["comment"] as? String,
                              let stars = reviewDict["stars"] as? Int,
                              let reviewDate = reviewDict["createdAt"] as? Timestamp else { return nil }
                        return Review(userId: userId, username: username, comment: comment, stars: stars, createdAt: reviewDate.dateValue())
                    }

                    let ratingBreakdown = RatingBreakdown(
                        averageRating: ratingBreakdownData["averageRating"] as? Double ?? 0.0,
                        totalReviews: ratingBreakdownData["totalReviews"] as? Int ?? 0,
                        fiveStar: ratingBreakdownData["fiveStar"] as? Int ?? 0,
                        fourStar: ratingBreakdownData["fourStar"] as? Int ?? 0,
                        threeStar: ratingBreakdownData["threeStar"] as? Int ?? 0,
                        twoStar: ratingBreakdownData["twoStar"] as? Int ?? 0,
                        oneStar: ratingBreakdownData["oneStar"] as? Int ?? 0
                    )

                    let seller = SellerDetails(
                        sellerId: sellerData["sellerId"] as? String ?? "",
                        sellerName: sellerData["sellerName"] as? String ?? "",
                        contactEmail: sellerData["contactEmail"] as? String ?? "",
                        contactPhone: sellerData["contactPhone"] as? String,
                        address: sellerData["address"] as? String,
                        sellerRating: sellerData["sellerRating"] as? Double ?? 0.0,
                        verified: sellerData["verified"] as? Bool ?? false
                    )

                    let deliveryDetails = DeliveryDetails(
                        estimatedDelivery: (deliveryData["estimatedDelivery"] as? Timestamp)?.dateValue() ?? Date(),
                        shippingCost: deliveryData["shippingCost"] as? Double ?? 0.0,
                        deliveryStatus: DeliveryStatus(rawValue: deliveryData["deliveryStatus"] as? String ?? "pending") ?? .pending
                    )

                    return Product(
                        id: document.documentID,
                        name: name,
                        description: description,
                        price: price,
                        imageUrls: imageUrls,
                        threeDModelUrl: threeDModelUrl,
                        view360Urls: view360Urls,
                        category: category,
                        stock: stock,
                        rating: rating,
                        reviews: reviews,
                        ratingBreakdown: ratingBreakdown,
                        discount: discount,
                        createdAt: createdAt.dateValue(),
                        seller: seller,
                        specifications: data["specifications"] as? [String: String] ?? [:],
                        variations: [],
                        isFeatured: data["isFeatured"] as? Bool ?? false,
                        isAvailable: data["isAvailable"] as? Bool ?? true,
                        deliveryDetails: deliveryDetails,
                        similarProducts: []
                    )
                }
                completion(.success(products))
            }
        }
    }

    // MARK: - Update Product
       func updateProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
           let data: [String: Any] = [
               "id": product.id,
               "name": product.name,
               "description": product.description,
               "price": product.price,
               "imageUrls": product.imageUrls,
               "threeDModelUrl": product.threeDModelUrl ?? "",
               "view360Urls": product.view360Urls ?? [],
               "category": product.category,
               "stock": product.stock,
               "rating": product.rating,
               "reviews": product.reviews.map { [
                   "userId": $0.userId,
                   "username": $0.username,
                   "comment": $0.comment,
                   "stars": $0.stars,
                   "createdAt": $0.createdAt
               ]},
               "ratingBreakdown": [
                   "averageRating": product.ratingBreakdown.averageRating,
                   "totalReviews": product.ratingBreakdown.totalReviews,
                   "fiveStar": product.ratingBreakdown.fiveStar,
                   "fourStar": product.ratingBreakdown.fourStar,
                   "threeStar": product.ratingBreakdown.threeStar,
                   "twoStar": product.ratingBreakdown.twoStar,
                   "oneStar": product.ratingBreakdown.oneStar
               ],
               "discount": product.discount,
               "createdAt": product.createdAt,
               "seller": [
                   "sellerId": product.seller.sellerId,
                   "sellerName": product.seller.sellerName,
                   "contactEmail": product.seller.contactEmail,
                   "contactPhone": product.seller.contactPhone ?? "",
                   "address": product.seller.address ?? "",
                   "sellerRating": product.seller.sellerRating,
                   "verified": product.seller.verified
               ],
               "specifications": product.specifications,
               "variations": product.variations.map { [
                   "variationId": $0.variationId,
                   "color": $0.color ?? "",
                   "size": $0.size ?? "",
                   "stock": $0.stock,
                   "additionalPrice": $0.additionalPrice
               ]},
               "isFeatured": product.isFeatured,
               "isAvailable": product.isAvailable,
               "isPinned": product.isPinned,  // ✅ Added pinned status
               "isFavorite": product.isFavorite,  // ✅ Added favorite status
               "deliveryDetails": [
                   "estimatedDelivery": product.deliveryDetails.estimatedDelivery,
                   "shippingCost": product.deliveryDetails.shippingCost,
                   "deliveryStatus": product.deliveryDetails.deliveryStatus.rawValue
               ],
               "similarProducts": product.similarProducts.map { [
                   "id": $0.id,
                   "name": $0.name,
                   "price": $0.price,
                   "imageUrl": $0.imageUrl,
                   "rating": $0.rating
               ]}
           ]

           db.collection("products").document(product.id!).updateData(data) { error in
               if let error = error {
                   completion(.failure(error))
               } else {
                   completion(.success(()))
               }
           }
       }

       // MARK: - Delete Product
       func deleteProduct(productId: String, completion: @escaping (Result<Void, Error>) -> Void) {
           db.collection("products").document(productId).delete { error in
               if let error = error {
                   completion(.failure(error))
               } else {
                   completion(.success(()))
               }
           }
       }

    func toggleFavorite(product: Product,newFavoriteStatus:Bool, completion: @escaping (Result<Void, Error>) -> Void) {
           guard let productId = product.id else { return }
           // Update Firestore
           db.collection("products").document(productId).updateData([
               "isFavorite": newFavoriteStatus
           ]) { error in
               if let error = error {
                   print("Error updating favorite status: \(error.localizedDescription)")
                   completion(.failure(error))
               }else{
                   completion(.success(()))

               }
           }
       }
    
       // MARK: - Upload Image to Firebase Storage
       func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
           guard let imageData = image.jpegData(compressionQuality: 0.7) else {
               completion(.failure(NSError(domain: "Image Error", code: 0, userInfo: nil)))
               return
           }

           let imageName = UUID().uuidString
           let storageRef = storage.reference().child("product_images/\(imageName).jpg")

           storageRef.putData(imageData, metadata: nil) { _, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }
               storageRef.downloadURL { url, error in
                   if let error = error {
                       completion(.failure(error))
                   } else if let url = url {
                       completion(.success(url.absoluteString))
                   }
               }
           }
       }

       // MARK: - Download Image from Firebase Storage
       func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
           let storageRef = storage.reference(forURL: urlString)
           storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
               if let error = error {
                   completion(.failure(error))
               } else if let data = data, let image = UIImage(data: data) {
                   completion(.success(image))
               } else {
                   completion(.failure(NSError(domain: "Image Error", code: 0, userInfo: nil)))
               }
           }
       }
}
