//
//  ProductListView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var isAddingProduct = false  // Controls Add Product modal

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.products.isEmpty {
                    // Show Empty State if No Products
                    VStack {
                        Image(systemName: "cart.fill.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                        Text("No products available")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    // List of Products
                    List(viewModel.products) { product in
                        NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                            ProductRowView(product: product)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .onAppear {
                viewModel.fetchProducts()
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingProduct.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Product")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $isAddingProduct) {
                AddProductView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Product Row View
struct ProductRowView: View {
    let product: Product

    var body: some View {
        HStack {
            if let imageUrl = product.imageUrls.first, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    ProgressView()
                        .frame(width: 60, height: 60)
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(product.name)
                    .font(.headline)
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.green)
                Text(product.category)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}
