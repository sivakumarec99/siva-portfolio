//
//  ProductListView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import Foundation
import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.products) { product in
                NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.headline)
                        Text("$\(product.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
            }
            .onAppear {
                viewModel.fetchProducts()
            }
            .navigationTitle("Products")
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}
