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
                if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable().scaledToFit().frame(height: 250).cornerRadius(10)
                        case .failure:
                            Image(systemName: "photo").resizable().scaledToFit().frame(height: 250)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo").resizable().scaledToFit().frame(height: 250)
                }

                Text(product.name).font(.title).fontWeight(.bold)
                Text("$\(product.price, specifier: "%.2f")").font(.title2).foregroundColor(.green)
                Text(product.description).font(.body).foregroundColor(.secondary)

                Spacer()

                HStack {
                    Button("Edit") {
                        showEditScreen.toggle()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Delete") {
                        showDeleteConfirmation.toggle()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
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
                }
            }
        }
        .alert("Delete Product", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteProduct(productId: product.id)
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

