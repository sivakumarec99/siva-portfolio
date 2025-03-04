//
//  ProductDetailView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import SwiftUI

struct ProductDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showEditScreen = false
    @State private var showDeleteConfirmation = false
    @ObservedObject var viewModel: ProductViewModel
    var product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product Images
                if !product.imageUrls.isEmpty, let firstImageUrl = product.imageUrls.first, let url = URL(string: firstImageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .cornerRadius(10)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .foregroundColor(.gray)
                }

                // Product Details
                Text(product.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("$\(product.price, specifier: "%.2f")")
                    .font(.title2)
                    .foregroundColor(.green)
                    .bold()
                
                if product.discount > 0 {
                    Text("Discount: \(product.discount * 100, specifier: "%.0f")% OFF")
                        .font(.headline)
                        .foregroundColor(.red)
                }

                Divider()

                Text("Category: \(product.category)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(product.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)

                Divider()

                HStack {
                    Text("Stock: \(product.stock)")
                        .font(.subheadline)
                        .foregroundColor(product.stock > 0 ? .blue : .red)
                        .bold()
                    
                    Spacer()
                    
                    Text("Rating: \(product.rating, specifier: "%.1f") ⭐️")
                        .font(.subheadline)
                        .bold()
                }
                
                // Seller Info
                if !product.seller.sellerName.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Divider()
                        Text("Seller: \(product.seller.sellerName)")
                            .font(.headline)
                        Text("Contact: \(product.seller.contactEmail)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Action Buttons
                HStack {
                    Button(action: { showEditScreen.toggle() }) {
                        Label("Edit", systemImage: "pencil.circle.fill")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: { showDeleteConfirmation.toggle() }) {
                        Label("Delete", systemImage: "trash.fill")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("Product Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Edit") {
                        showEditScreen.toggle()
                    }
                    Button("Delete", role: .destructive) {
                        showDeleteConfirmation.toggle()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                }
            }
        }
        .alert("Delete Product", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteProduct(productId: product.id!)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this product?")
        }
        .sheet(isPresented: $showEditScreen) {
            ProductFormView(viewModel: viewModel, product: product)
        }
    }
}
