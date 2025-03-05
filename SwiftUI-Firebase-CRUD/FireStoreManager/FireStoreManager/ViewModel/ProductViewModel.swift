//
//  ProductViewModel.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//
import SwiftUI

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var selectedProduct: Product?
    @Published var isEditViewPresented = false
    private let firestoreService = FirestoreService()

    var favoriteProducts: [Product] {
           return products.filter { $0.isFavorite }
       }
    
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
    // MARK: - Fav Product
    func toggleFavorite(_ product: Product) {
        guard let productId = product.id else { return }
        let newFavoriteStatus = !product.isFavorite
        firestoreService.toggleFavorite(product: product,newFavoriteStatus: newFavoriteStatus) { result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success:
                    // Update local UI
                    if let index = self.products.firstIndex(where: { $0.id == productId }) {
                        self.products[index].isFavorite.toggle()
                        self.products.sort(by: self.sortingLogic)
                        objectWillChange.send()
                    }
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
    
    
    func addToCart(_ product: Product) {
          print("\(product.name) added to cart")
      }

//      func toggleFavorite(_ product: Product) {
//          if let index = products.firstIndex(where: { $0.id == product.id }) {
//              products[index].isFavorite.toggle()
//              products.sort(by: sortingLogic)
//              objectWillChange.send()
//          }
//      }

    func pinProduct(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].isPinned.toggle()
            products.sort(by: sortingLogic)
        }
    }

      func updateStock(productId: String, newStock: Int) {
          if let index = products.firstIndex(where: { $0.id == productId }) {
              products[index].stock = newStock
              products[index].isAvailable = newStock > 0
              products.sort(by: sortingLogic)
          }
      }

    private func sortingLogic(_ p1: Product, _ p2: Product) -> Bool {
        // 1️⃣ Pinned products first
        if p1.isPinned != p2.isPinned {
            return p1.isPinned
        }
        // 2️⃣ Featured products next
        if p1.isFeatured != p2.isFeatured {
            return p1.isFeatured
        }
        // 3️⃣ Available products next
        if p1.isAvailable != p2.isAvailable {
            return p1.isAvailable
        }
        // 4️⃣ Higher-rated products next
        if p1.rating != p2.rating {
            return p1.rating > p2.rating
        }
        // 5️⃣ Sort by newest
        return p1.createdAt > p2.createdAt
    }

      func sortedProducts() -> [Product] {
          return products.sorted(by: sortingLogic)
      }
    
    func refreshDeals() {
            products = products.filter { $0.timeLeft != nil } // Remove expired deals
    }
}
