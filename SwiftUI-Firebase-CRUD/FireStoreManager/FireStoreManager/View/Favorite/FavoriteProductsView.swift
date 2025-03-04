//
//  FavoriteProductsView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 04/03/25.
//

import Foundation
import SwiftUI

struct FavoriteProductsView: View {
    @ObservedObject var viewModel: ProductViewModel

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.favoriteProducts.isEmpty {
                    EmptyStateView(message: "No favorite products yet! ❤️")
                } else {
                    List(viewModel.favoriteProducts) { product in
                        ProductRowView(
                            viewModel:viewModel,
                            product: product,
                            isSelected: false,
                            toggleFavorite: { viewModel.toggleFavorite(product) },
                            pinProduct: { viewModel.pinProduct(product) }
                        )                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Favorites ❤️")
        }
    }
}
