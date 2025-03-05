//
//  AddProductViewModel.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 05/03/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

class AddProductViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var price: String = ""
    @Published var category: String = ""
    @Published var stock: String = ""
    @Published var image: UIImage? = nil
    @Published var imageUrl: String? = nil
    @Published var isFeatured: Bool = false
    @Published var isPinned: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    var existingProduct: Product?  // If editing, this will be set

    init(product: Product? = nil) {
        if let product = product {
            self.existingProduct = product
            self.name = product.name
            self.description = product.description
            self.price = String(product.price)
            self.category = product.category
            self.stock = String(product.stock)
            self.imageUrl = product.imageUrls.first // Use existing image
            self.isFeatured = product.isFeatured
            self.isPinned = product.isPinned
        }
    }

    func saveProduct(completion: @escaping (Bool) -> Void) {
        guard !name.isEmpty, !price.isEmpty, let priceValue = Double(price), let stockValue = Int(stock) else {
            errorMessage = "Please fill all required fields correctly."
            completion(false)
            return
        }
        
        isLoading = true
        
        // If an image is selected, upload it
        if let selectedImage = image {
            uploadImage(selectedImage) { [weak self] url in
                guard let self = self else { return }
                if let url = url {
                    self.imageUrl = url
                }
                self.saveToFirestore(completion: completion)
            }
        } else {
            // No new image, just save product
            saveToFirestore(completion: completion)
        }
    }

    private func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let storageRef = storage.reference().child("product_images/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                completion(url?.absoluteString)
            }
        }
    }

    private func saveToFirestore(completion: @escaping (Bool) -> Void) {
        var productData: [String: Any] = [
            "name": name,
            "description": description,
            "price": Double(price) ?? 0.0,
            "category": category,
            "stock": Int(stock) ?? 0,
            "isFeatured": isFeatured,
            "isPinned": isPinned,
            "imageUrls": imageUrl != nil ? [imageUrl!] : []
        ]

        if let existingProduct = existingProduct {
            // Editing an existing product
            db.collection("products").document(existingProduct.id!).updateData(productData) { error in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } else {
            // Adding a new product
            db.collection("products").addDocument(data: productData) { error in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
