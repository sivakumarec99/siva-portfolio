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

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var image: UIImage?
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var isUploading = false
    @State private var errorMessage: String?

    var isEditing: Bool {
        product != nil
    }

    init(viewModel: ProductViewModel, product: Product? = nil) {
        self.viewModel = viewModel
        self.product = product
        if let product = product {
            _name = State(initialValue: product.name)
            _description = State(initialValue: product.description)
            _price = State(initialValue: String(format: "%.2f", product.price))
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Image")) {
                    PhotosPicker(selection: $selectedImageItem, matching: .images) {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                        } else if let url = URL(string: product?.imageUrl ?? "") {
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

                Section(header: Text("Product Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

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
        .onChange(of: selectedImageItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    image = UIImage(data: data)
                }
            }
        }
    }

    private func saveProduct() {
        guard !name.isEmpty, !description.isEmpty, let priceValue = Double(price) else {
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
            saveToFirestore(imageUrl: product?.imageUrl)
        }
    }

    private func saveToFirestore(imageUrl: String?) {
        if isEditing, let product = product {
            let updatedProduct = Product(id: product.id, name: name, description: description, price: Double(price) ?? 0, imageUrl: imageUrl, createdAt: product.createdAt)
            viewModel.updateProduct(updatedProduct)
        } else {
            viewModel.addProduct(name: name, description: description, price: Double(price) ?? 0, imageUrl: imageUrl)
        }
        presentationMode.wrappedValue.dismiss()
    }
}
