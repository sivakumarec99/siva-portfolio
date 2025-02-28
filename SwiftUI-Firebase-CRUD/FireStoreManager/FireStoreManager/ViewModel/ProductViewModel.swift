//
//  ProductViewModel.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import SwiftUI

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
    func addProduct(name: String, description: String, price: Double, imageUrl: String?) {
        let newProduct = Product(id: UUID().uuidString, name: name, description: description, price: price, imageUrl: imageUrl, createdAt: Date())
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
}
