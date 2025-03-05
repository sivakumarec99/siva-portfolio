//
//  AddProductView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 03/03/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct AddProductView: View {
    @ObservedObject var viewModel: ProductViewModel
    var product: Product?

    @Environment(\.presentationMode) var presentationMode
    
    // State Variables for Product Fields
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var category = "Electronics"
    @State private var stock = 1
    @State private var rating = 3.0
    @State private var discount = ""
    @State private var specifications: [String: String] = [:]
    @State private var isFeatured = false
    @State private var isAvailable = true
    
    // Media Upload States
    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideoURL: URL? = nil
    @State private var uploadedImageURLs: [String] = []
    @State private var uploadedVideoURL: String? = nil
    @State private var isPickerPresented = false
    @State private var isUploading = false
    
    let categories = ["Electronics", "Clothing", "Home & Kitchen", "Books", "Toys"]

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Product Details
                Section(header: Text("Product Details")) {
                    TextField("Product Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Price ($)", text: $price)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    
                    Stepper("Stock: \(stock)", value: $stock, in: 1...100)
                    Stepper("Rating: \(rating, specifier: "%.1f")", value: $rating, in: 1...5, step: 0.1)
                    TextField("Discount (%)", text: $discount)
                        .keyboardType(.decimalPad)
                    
                    Toggle("Featured Product", isOn: $isFeatured)
                    Toggle("Available for Sale", isOn: $isAvailable)
                }
                
                // MARK: - Specifications
                Section(header: Text("Specifications")) {
                    ForEach(specifications.keys.sorted(), id: \.self) { key in
                        HStack {
                            Text(key).bold()
                            Spacer()
                            Text(specifications[key] ?? "")
                        }
                    }
                    Button("Add Specification") {
                        addSpecification()
                    }
                }
                
                // MARK: - Media Upload
                Section(header: Text("Upload Media")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                            if let videoURL = selectedVideoURL {
                                VideoThumbnailView(videoURL: videoURL)
                            }
                        }
                    }
                    
                    Button("Select Media") {
                        isPickerPresented.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // MARK: - Submit Button
                Section {
                    Button(action: uploadMediaAndSaveProduct) {
                        if isUploading {
                            ProgressView()
                        } else {
                            Text("Add Product")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .disabled(!isValidInput() || isUploading)
                }
            }
            .navigationTitle("Add Product")
        }
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(selectedImages: $selectedImages, selectedVideoURL: $selectedVideoURL)
        }
    }
    
    /// Uploads media first, then saves the product
    private func uploadMediaAndSaveProduct() {
        isUploading = true
        
        uploadMedia { success in
            if success {
                saveProduct()
            } else {
                print("❌ Failed to upload media")
                isUploading = false
            }
        }
    }
    
    /// Uploads images and videos to Firebase Storage
    private func uploadMedia(completion: @escaping (Bool) -> Void) {
        let dispatchGroup = DispatchGroup()
        var uploadedImages: [String] = []
        var uploadedVideo: String? = nil
        
        // Upload images
        for image in selectedImages {
            dispatchGroup.enter()
            FirebaseStorageManager.shared.uploadImage(image) { result in
                switch result {
                case .success(let url):
                    uploadedImages.append(url)
                case .failure(let error):
                    print("❌ Image upload error: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        // Upload video if available
        if let videoURL = selectedVideoURL {
            dispatchGroup.enter()
            FirebaseStorageManager.shared.uploadVideo(videoURL) { result in
                switch result {
                case .success(let url):
                    uploadedVideo = url
                case .failure(let error):
                    print("❌ Video upload error: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.uploadedImageURLs = uploadedImages
            self.uploadedVideoURL = uploadedVideo
            completion(true)
        }
    }
    
    /// Saves the product to Firestore
    private func saveProduct() {
        guard let priceValue = Double(price) else {
            print("❌ Invalid price")
            isUploading = false
            return
        }

        let discountValue = Double(discount.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
        let createdAtDate = Date()
        let sellerId = Auth.auth().currentUser?.uid ?? UUID().uuidString

        // Call ViewModel function directly with parameters instead of creating a Product
        viewModel.addProduct(
            name: name,
            description: description,
            price: priceValue,
            imageUrls: uploadedImageURLs,
            threeDModelUrl: nil,
            view360Urls: [],
            category: category,
            stock: stock,
            rating: rating,
            discount: discountValue,
            seller: SellerDetails(
                sellerId: sellerId,
                sellerName: "Unknown Seller",
                contactEmail: "unknown@example.com",
                contactPhone: nil,
                address: nil,
                sellerRating: 0.0,
                verified: false
            ),
            specifications: specifications,
            variations: [],
            isFeatured: isFeatured,
            isAvailable: isAvailable,
            deliveryDetails: DeliveryDetails(
                estimatedDelivery: Calendar.current.date(byAdding: .day, value: 5, to: createdAtDate) ?? createdAtDate,
                shippingCost: 0.0,
                deliveryStatus: .pending
            )
        )

        isUploading = false
        presentationMode.wrappedValue.dismiss()
    }
    
    /// Validates input before enabling submission
    private func isValidInput() -> Bool {
        return !name.isEmpty && !description.isEmpty && !price.isEmpty
    }
    
    /// Adds a placeholder specification for testing
    private func addSpecification() {
        specifications["New Spec"] = "Value"
    }
}
