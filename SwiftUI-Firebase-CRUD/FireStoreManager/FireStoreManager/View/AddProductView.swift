//
//  AddProductView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 03/03/25.
//

import SwiftUI
import FirebaseAuth

struct AddProductView: View {
    @StateObject var viewModel = ProductViewModel()
    
    // Form Fields
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var imageUrl = ""
    @State private var category = "Electronics"
    @State private var stock = 1
    @State private var rating = 3.0
    @State private var discount = ""
    
    @Environment(\.presentationMode) var presentationMode

    // Predefined categories
    let categories = ["Electronics", "Clothing", "Home & Kitchen", "Books", "Toys"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Details")) {
                    TextField("Product Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Price ($)", text: $price)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section(header: Text("Additional Info")) {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }

                    Stepper("Stock: \(stock)", value: $stock, in: 1...100)

                    Stepper("Rating: \(rating, specifier: "%.1f")", value: $rating, in: 1...5, step: 0.1)

                    TextField("Discount (%)", text: $discount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section(header: Text("Image")) {
                    TextField("Image URL", text: $imageUrl)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section {
                    Button(action: addProduct) {
                        Text("Add Product")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isValidInput())

                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Add Product")
        }
    }
    
    private func addProduct() {
        guard let priceValue = Double(price) else {
            print("Invalid price")
            return
        }

        let stockValue = Int(stock) ?? 0
        let ratingValue = Double(rating) ?? 0.0
        let discountValue = (Double(discount.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0) > 0 ? Double(discount) : nil

        let sellerDetails = SellerDetails(
            sellerId: Auth.auth().currentUser?.uid ?? UUID().uuidString, // Use Firebase UID or generate a fallback ID
            sellerName: "Unknown Seller", // Replace with user input if available
            contactEmail: "unknown@example.com",
            contactPhone: nil,
            address: nil,
            sellerRating: 0.0, // Default rating
            verified: false // Assume not verified by default
        )

        let deliveryInfo = DeliveryDetails(
            estimatedDelivery: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(), // 5 days from now
            shippingCost: 0.0, // Free shipping
            deliveryStatus: .pending // Default status
        )

        viewModel.addProduct(
            name: name,
            description: description,
            price: priceValue,
            imageUrls: imageUrl.isEmpty ? [] : [imageUrl], // Ensure array type
            threeDModelUrl: nil,
            view360Urls: [],
            category: category,
            stock: stockValue,
            rating: ratingValue,
            discount: discountValue ?? 0.0,
            seller: sellerDetails, // Now using a valid SellerDetails object
            specifications: [:], // Empty dictionary as default
            variations: [],
            isFeatured: false,
            isAvailable: true,
            deliveryDetails: deliveryInfo // Now using a valid DeliveryDetails object
        )

        presentationMode.wrappedValue.dismiss()
    }
    private func isValidInput() -> Bool {
        return !name.isEmpty && !description.isEmpty && !price.isEmpty
    }
}
