//
//  ProductViewModel.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//
import SwiftUI
import Firebase

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    private let firestoreService = FirestoreService()

    // MARK: - Fetch Products
    func fetchProducts() {
        firestoreService.fetchProducts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    self.products = products
                case .failure(let error):
                    print("Error fetching products: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Add Product
    func addProduct(
        name: String,
        description: String,
        price: Double,
        imageUrls: [String],
        threeDModelUrl: String?,
        view360Urls: [String]?,
        category: String,
        stock: Int,
        rating: Double,
        discount: Double,
        seller: SellerDetails,
        specifications: [String: String],
        variations: [ProductVariation],
        isFeatured: Bool,
        isAvailable: Bool,
        deliveryDetails: DeliveryDetails
    ) {
        let newProduct = Product(
            id: UUID().uuidString,
            name: name,
            description: description,
            price: price,
            imageUrls: imageUrls,
            threeDModelUrl: threeDModelUrl,
            view360Urls: view360Urls,
            category: category,
            stock: stock,
            rating: rating,
            reviews: [],
            ratingBreakdown: RatingBreakdown(averageRating: rating, totalReviews: 0, fiveStar: 0, fourStar: 0, threeStar: 0, twoStar: 0, oneStar: 0),
            discount: discount,
            createdAt: Date(),
            seller: seller,
            specifications: specifications,
            variations: variations,
            isFeatured: isFeatured,
            isAvailable: isAvailable,
            deliveryDetails: deliveryDetails,
            similarProducts: []
        )

        firestoreService.addProduct(newProduct) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.fetchProducts()
                case .failure(let error):
                    print("Error adding product: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Update Product
    func updateProduct(_ product: Product) {
        firestoreService.updateProduct(product) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.fetchProducts()
                case .failure(let error):
                    print("Error updating product: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Delete Product
    func deleteProduct(productId: String) {
        firestoreService.deleteProduct(productId: productId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.products.removeAll { $0.id == productId }
                case .failure(let error):
                    print("Error deleting product: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Upload Image
    func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        firestoreService.uploadImage(image: image) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    // MARK: - Download Image
    func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        firestoreService.downloadImage(urlString: urlString) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
