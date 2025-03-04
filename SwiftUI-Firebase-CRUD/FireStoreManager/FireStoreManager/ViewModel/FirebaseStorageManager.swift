//
//  FirebaseStorageManager.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 04/03/25.
//

import Foundation
import FirebaseStorage
import UIKit

class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    private let storageRef = Storage.storage().reference()

    // Upload Image
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversion", code: -1, userInfo: nil)))
            return
        }

        let fileName = UUID().uuidString + ".jpg"
        let imageRef = storageRef.child("images/\(fileName)")

        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(url?.absoluteString ?? ""))
            }
        }
    }

    // Upload Video
    func uploadVideo(_ videoURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let fileName = UUID().uuidString + ".mp4"
        let videoRef = storageRef.child("videos/\(fileName)")

        videoRef.putFile(from: videoURL, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            videoRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(url?.absoluteString ?? ""))
            }
        }
    }
}
