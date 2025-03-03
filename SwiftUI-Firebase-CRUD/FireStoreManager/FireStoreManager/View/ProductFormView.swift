//
//  ProductFormView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import SwiftUI
import PhotosUI

struct ProductFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ProductViewModel
    var product: Product?

    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var stock = ""
    @State private var rating = ""
    @State private var discount = ""
    @State private var category = ""
    @State private var sellerName = ""
    @State private var sellerEmail = ""
    @State private var estimatedDelivery = Date()
    @State private var shippingCost = ""
    @State private var image: UIImage?
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var isUploading = false
    @State private var errorMessage: String?

    var isEditing: Bool {
        product != nil
    }

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Product Image Section
                Section(header: Text("Product Image")) {
                    PhotosPicker(selection: $selectedImageItem, matching: .images) {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                        } else if let imageUrl = product?.imageUrls.first, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable().scaledToFit().frame(height: 150)
                                case .failure:
                                    Image(systemName: "photo").resizable().scaledToFit().frame(height: 150)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "photo").resizable().scaledToFit().frame(height: 150)
                        }
                    }
                }

                // MARK: - Product Details
                Section(header: Text("Product Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Stock Quantity", text: $stock)
                        .keyboardType(.numberPad)
                    TextField("Rating (1-5)", text: $rating)
                        .keyboardType(.decimalPad)
                    TextField("Discount (%)", text: $discount)
                        .keyboardType(.decimalPad)
                    TextField("Category", text: $category)
                }

                // MARK: - Seller Information
                Section(header: Text("Seller Information")) {
                    TextField("Seller Name", text: $sellerName)
                    TextField("Seller Email", text: $sellerEmail)
                        .keyboardType(.emailAddress)
                }

                // MARK: - Delivery Details
                Section(header: Text("Delivery Details")) {
                    DatePicker("Estimated Delivery", selection: $estimatedDelivery, displayedComponents: .date)
                    TextField("Shipping Cost", text: $shippingCost)
                        .keyboardType(.decimalPad)
                }

                // MARK: - Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // MARK: - Save Button
                Button(action: saveProduct) {
                    HStack {
                        if isUploading {
                            ProgressView()
                        } else {
                            Text(isEditing ? "Update Product" : "Add Product")
                        }
                    }
                }
                .disabled(isUploading)
            }
            .navigationTitle(isEditing ? "Edit Product" : "Add Product")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let product = product {
                name = product.name
                description = product.description
                price = String(format: "%.2f", product.price)
                stock = "\(product.stock ?? 0)"
                rating = String(format: "%.1f", product.rating ?? 0.0)
                discount = product.discount != nil ? String(format: "%.0f", (product.discount ?? 0) * 100) : ""
                category = product.category ?? ""
                sellerName = product.seller.sellerName
                sellerEmail = product.seller.contactEmail
                estimatedDelivery = product.deliveryDetails.estimatedDelivery ?? Date()
                shippingCost = String(format: "%.2f", product.deliveryDetails.shippingCost ?? 0.0)
            }
        }
        .onChange(of: selectedImageItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    image = UIImage(data: data)
                }
            }
        }
    }

    // MARK: - Save Product
    private func saveProduct() {
        guard !name.isEmpty,
              !description.isEmpty,
              let priceValue = Double(price),
              let stockValue = Int(stock),
              let ratingValue = Double(rating),
              let discountValue = Double(discount) else {
            errorMessage = "Please enter valid details."
            return
        }

        errorMessage = nil
        isUploading = true

        if let image = image {
            viewModel.uploadImage(image: image) { result in
                switch result {
                case .success(let url):
                    saveToFirestore(imageUrl: url)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    isUploading = false
                }
            }
        } else {
            saveToFirestore(imageUrl: product?.imageUrls.first)
        }
    }

    // MARK: - Save to Firestore
    private func saveToFirestore(imageUrl: String?) {
        guard let priceValue = Double(price),
              let stockValue = Int(stock),
              let ratingValue = Double(rating),
              let discountValue = Double(discount) else {
            errorMessage = "Please enter valid details."
            isUploading = false
            return
        }

        let seller = SellerDetails(
            sellerId: product?.seller.sellerId ?? UUID().uuidString,
            sellerName: sellerName,
            contactEmail: sellerEmail,
            contactPhone: product?.seller.contactPhone,
            address: product?.seller.address,
            sellerRating: product?.seller.sellerRating ?? 0.0,
            verified: product?.seller.verified ?? false
        )

        let deliveryDetails = DeliveryDetails(
            estimatedDelivery: estimatedDelivery,
            shippingCost: Double(shippingCost) ?? 0.0,
            deliveryStatus: product?.deliveryDetails.deliveryStatus ?? .pending
        )

        // Default values
        let defaultSpecifications: [String: String] = [:] // Dictionary instead of an array
        let defaultVariations: [ProductVariation] = []    // Changed to expected type
        let defaultThreeDModelUrl: String? = nil
        let defaultView360Urls: [String] = []
        let defaultReviews: [Review] = []
        let defaultRatingBreakdown = RatingBreakdown(
            averageRating: 0.0,
            totalReviews: 0,
            fiveStar: 0,
            fourStar: 0,
            threeStar: 0,
            twoStar: 0,
            oneStar: 0
        )  
        let defaultSimilarProducts: [SimilarProduct] = [] // Changed to expected type
        let defaultIsFeatured = false
        let defaultIsAvailable = true

        if isEditing, let product = product {
            let updatedProduct = Product(
                id: product.id,
                name: name,
                description: description,
                price: priceValue,
                imageUrls: imageUrl != nil ? [imageUrl!] : product.imageUrls,
                threeDModelUrl: product.threeDModelUrl ?? defaultThreeDModelUrl,
                view360Urls: product.view360Urls ?? defaultView360Urls,
                category: category,
                stock: stockValue,
                rating: ratingValue,
                reviews: product.reviews ?? defaultReviews,
                ratingBreakdown: product.ratingBreakdown ?? defaultRatingBreakdown,
                discount: discountValue / 100,
                createdAt: product.createdAt,
                seller: seller,
                specifications: product.specifications ?? defaultSpecifications, // Updated
                variations: product.variations ?? defaultVariations,             // Updated
                isFeatured: product.isFeatured ?? defaultIsFeatured,
                isAvailable: product.isAvailable ?? defaultIsAvailable,
                deliveryDetails: deliveryDetails,
                similarProducts: product.similarProducts ?? defaultSimilarProducts // Updated
            )
            viewModel.updateProduct(updatedProduct)
        } else {
            let newProduct = Product(
                id: UUID().uuidString,
                name: name,
                description: description,
                price: priceValue,
                imageUrls: imageUrl != nil ? [imageUrl!] : [],
                threeDModelUrl: defaultThreeDModelUrl,
                view360Urls: defaultView360Urls,
                category: category,
                stock: stockValue,
                rating: ratingValue,
                reviews: defaultReviews,
                ratingBreakdown: defaultRatingBreakdown,
                discount: discountValue / 100,
                createdAt: Date(),
                seller: seller,
                specifications: defaultSpecifications,  // Updated
                variations: defaultVariations,         // Updated
                isFeatured: defaultIsFeatured,
                isAvailable: defaultIsAvailable,
                deliveryDetails: deliveryDetails,
                similarProducts: defaultSimilarProducts // Updated
            )
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

        isUploading = false
        presentationMode.wrappedValue.dismiss()
    }
}
