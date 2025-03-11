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
    @State private var showFavorites = false
    @State private var selectedProductIds = Set<String>()
    @State private var isGridView = false  // ✅ Toggle between List and Grid

    private let gridColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationView {
            ZStack {                
                VStack {
                    if viewModel.products.isEmpty {
                        EmptyStateView(message: "No products available")
                    } else {
                        viewSwitcher
                    }
                }
                .onAppear {
                    viewModel.fetchProducts()
                }
                .navigationTitle("Products")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { isGridView.toggle() }) {
                            Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2.fill")
                                .font(.headline)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        toolbarButtons
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

    private var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .white]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }

    // ✅ Toggle between List and Grid View
    private var viewSwitcher: some View {
        Group {
            if isGridView {
                LazyVGrid(columns: gridColumns, spacing: 15) {
                    ForEach(viewModel.sortedProducts(), id: \.id) { product in
                        gridItem(for: product)
                    }
                }
                .padding(.horizontal)
            } else {
                List(viewModel.sortedProducts(), id: \.id) { product in
                    productRow(for: product)
                }
                .listStyle(PlainListStyle())
            }
        }
        .animation(.easeInOut, value: isGridView)
    }

    // ✅ Grid View Item
    private func gridItem(for product: Product) -> some View {
        VStack {
            if let imageUrl = product.imageUrls.first, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    ProgressView()
                        .frame(width: 150, height: 150)
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
            }
            
            VStack {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 3))
        .onTapGesture {
            toggleSelection(for: product)
        }
    }

    // ✅ List Row View
    private func productRow(for product: Product) -> some View {
        NavigationLink(destination: AddProductView(viewModel: viewModel, product: product)) {
            ProductRowView(
                viewModel: viewModel,
                product: product,
                isSelected: selectedProductIds.contains(product.id ?? ""),
                toggleFavorite: { viewModel.toggleFavorite(product) },
                pinProduct: { viewModel.pinProduct(product) }
            )
            .padding(.vertical, 8)
        }
    }

    private var toolbarButtons: some View {
        HStack {
            Button(action: { isAddingProduct.toggle() }) {
                Image(systemName: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            Button(action: { showFavorites.toggle() }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
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
