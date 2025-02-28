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
            "imageUrl": product.imageUrl ?? "",
            "createdAt": product.createdAt
        ]
        db.collection("products").document(product.id).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Read Products
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
                          let createdAt = data["createdAt"] as? Timestamp else { return nil }
                    return Product(id: document.documentID,
                                   name: name,
                                   description: description,
                                   price: price,
                                   imageUrl: data["imageUrl"] as? String,
                                   createdAt: createdAt.dateValue())
                }
                completion(.success(products))
            }
        }
    }

    // MARK: - Update Product
    func updateProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        let data: [String: Any] = [
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl ?? "",
            "createdAt": product.createdAt
        ]
        db.collection("products").document(product.id).updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Delete Product
    func deleteProduct(_ productId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("products").document(productId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Upload Image
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
}
