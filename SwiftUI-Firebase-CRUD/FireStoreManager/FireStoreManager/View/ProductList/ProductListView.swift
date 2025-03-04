//
//  ProductListView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var isAddingProduct = false
    @State private var showFavorites = false  // Controls Favorite Products View
    @State private var selectedProductIds = Set<String>()  // For selection highlighting
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .white]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    if viewModel.products.isEmpty {
                        EmptyStateView(message:"No products available")
                    } else {
                        List {
                            ForEach(viewModel.sortedProducts()) { product in
                                ProductRowView(
                                    viewModel:viewModel,
                                    product: product,
                                    isSelected: selectedProductIds.contains(product.id!),
                                    toggleFavorite: { viewModel.toggleFavorite(product) },
                                    pinProduct: { viewModel.pinProduct(product) }
                                )
                                .swipeActions(edge: .leading) {
                                    Button {
                                        viewModel.addToCart(product)
                                    } label: {
                                        Label("Add to Cart", systemImage: "cart.fill")
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.deleteProduct(productId: product.id!)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .onTapGesture {
                                    toggleSelection(for: product)
                                }
                                .animation(.easeInOut, value: selectedProductIds)
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
                        HStack{
                            Button(action: {
                                isAddingProduct.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                }
                                .font(.headline)
                                .foregroundColor(.blue)
                            }
                            Button(action: { showFavorites.toggle() }) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showFavorites) {
                    FavoriteProductsView(viewModel: viewModel)
                }
                .sheet(isPresented: $isAddingProduct) {
                    AddProductView(viewModel: viewModel)
                }
            }
        }
    }
    
    
    private func toggleSelection(for product: Product) {
        if selectedProductIds.contains(product.id!) {
            selectedProductIds.remove(product.id!)
        } else {
            selectedProductIds.insert(product.id!)
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    @State var message:String
    var body: some View {
        VStack {
            Image(systemName: "cart.fill.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            Text(message)
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Product Row View
struct ProductRowView: View {
    let viewModel:ProductViewModel
    let product: Product
    let isSelected: Bool
    let toggleFavorite: () -> Void
    let pinProduct: () -> Void

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
                HStack {
                    Text(product.name)
                        .font(.headline)
                        .foregroundColor(isSelected ? .blue : .primary)
                    if product.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.red)
                    }
                }
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.green)
                Text(product.category)
                    .font(.footnote)
                    .foregroundColor(.gray)
                if product.discount > 0 {
                    Text("🔥 \(Int(product.discount))% OFF")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.red)
                }
                if let timeLeft = product.timeLeft {
                    Text("⏳ Deal ends in: \(timeLeft)")
                        .font(.footnote)
                        .foregroundColor(.orange)
                }
        
            }
            Spacer()

            Button(action: toggleFavorite) {
                Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(product.isFavorite ? .red : .gray)
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: pinProduct) {
                Image(systemName: "pin")
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(10)
    }
}

// MARK: - Preview
struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}
