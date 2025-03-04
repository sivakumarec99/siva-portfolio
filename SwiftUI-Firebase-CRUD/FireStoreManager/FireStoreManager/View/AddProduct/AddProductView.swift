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
    @ObservedObject var viewModel: ProductViewModel // Accept viewModel externally
    
    init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
    }
      
    // State Variables for Product Fields
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var category = "Electronics"
    @State private var stock = 1
    @State private var rating = 3.0
    @State private var discount = ""
    @State private var specifications: [String: String] = [:] // Key-Value Pairs
    @State private var isFeatured = false
    @State private var isAvailable = true
    
    // Media Upload States
    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideoURL: URL? = nil
    @State private var uploadedImageURLs: [String] = []
    @State private var uploadedVideoURL: String? = nil
    @State private var isPickerPresented = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let categories = ["Electronics", "Clothing", "Home & Kitchen", "Books", "Toys"]

    var body: some View {
            NavigationView {
                Form {
                    // MARK: - Product Details Section
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

                    // MARK: - Specifications Section
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

                    // MARK: - Media Upload Section
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
                        Button(action: uploadMediaAndAddProduct) {
                            Text("Add Product")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(!isValidInput())
                    }
                }
                .navigationTitle("Add Product")
            }
            .sheet(isPresented: $isPickerPresented) {
                ImagePicker(selectedImages: $selectedImages, selectedVideoURL: $selectedVideoURL)
            }
        }
    
    /// Uploads media first, then adds product
    private func uploadMediaAndAddProduct() {
        uploadMedia { success in
            if success {
                addProduct()
            } else {
                print("❌ Failed to upload media")
            }
        }
    }
    
    /// Upload Images and Video to Firebase Storage
    private func uploadMedia(completion: @escaping (Bool) -> Void) {
        let dispatchGroup = DispatchGroup()

        // Upload images
        for image in selectedImages {
            dispatchGroup.enter()
            FirebaseStorageManager.shared.uploadImage(image) { result in
                switch result {
                case .success(let url):
                    uploadedImageURLs.append(url)
                case .failure(let error):
                    print("❌ Error uploading image: \(error.localizedDescription)")
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
                    uploadedVideoURL = url
                case .failure(let error):
                    print("❌ Error uploading video: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(true)
        }
    }
    
    /// Saves the product to Firestore
    private func addProduct() {
        // Validate price
        guard let priceValue = Double(price) else {
            print("❌ Invalid price")
            return
        }

        // Validate discount
        let discountValue = Double(discount.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0

        // Generate unique product ID
        let productId = UUID().uuidString

        // Firestore-compatible Date
        let createdAtDate = Date()

        // Ensure we have a seller ID
        let sellerId = Auth.auth().currentUser?.uid ?? UUID().uuidString

        let sellerDetails = SellerDetails(
            sellerId: sellerId,
            sellerName: "Unknown Seller", // Can be updated later
            contactEmail: "unknown@example.com",
            contactPhone: nil,
            address: nil,
            sellerRating: 0.0,
            verified: false
        )

        // Ensure delivery details are structured properly
        let deliveryDetails = DeliveryDetails(
            estimatedDelivery: Calendar.current.date(byAdding: .day, value: 5, to: createdAtDate) ?? createdAtDate,
            shippingCost: 0.0,
            deliveryStatus: .pending
        )

        // Create a valid RatingBreakdown object
        let ratingBreakdown = RatingBreakdown(
            averageRating: 0, totalReviews: 0, fiveStar: 0, fourStar: 0, threeStar: 0,
            twoStar: Int(0.0), oneStar: 0
        )

        // Create product with complete details
        let newProduct = Product(
            id: productId,
            name: name,
            description: description,
            price: priceValue,
            imageUrls: uploadedImageURLs,
            threeDModelUrl: nil, // No 3D model for now
            view360Urls: [], // No 360-degree images for now
            category: category,
            stock: stock,
            rating: rating,
            reviews: [], // No reviews initially
            ratingBreakdown: ratingBreakdown, // Default rating breakdown
            discount: discountValue,
            createdAt: createdAtDate, // Converted to Firestore Timestamp when saving
            seller: sellerDetails,
            specifications: specifications,
            variations: [], // No variations initially
            isFeatured: isFeatured,
            isAvailable: isAvailable,
            deliveryDetails: deliveryDetails,
            similarProducts: [] // No similar products initially
        )

        // Upload product to Firestore
        viewModel.addProduct(
            name: newProduct.name,
            description: newProduct.description,
            price: newProduct.price,
            imageUrls: newProduct.imageUrls,
            threeDModelUrl: newProduct.threeDModelUrl,
            view360Urls: newProduct.view360Urls,
            category: newProduct.category,
            stock: newProduct.stock,
            rating: newProduct.rating,
            discount: newProduct.discount,
            seller: newProduct.seller,
            specifications: newProduct.specifications,
            variations: newProduct.variations,
            isFeatured: newProduct.isFeatured,
            isAvailable: newProduct.isAvailable,
            deliveryDetails: newProduct.deliveryDetails
        )
    }
    
    /// Validates product input before submission
    private func isValidInput() -> Bool {
        return !name.isEmpty && !description.isEmpty && !price.isEmpty
    }
    
    /// Adds a default specification (for testing)
    private func addSpecification() {
        specifications["New Spec"] = "Value"
    }
}
