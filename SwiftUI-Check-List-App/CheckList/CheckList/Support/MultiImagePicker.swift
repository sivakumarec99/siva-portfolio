//
//  MultiImagePicker.swift
//  CheckList
//
//  Created by JIDTP1408 on 14/03/25.
//

import Foundation
import PhotosUI
import SwiftUI

struct MultiImagePicker: View {
    @State private var selectedImages: [UIImage] = []
    @State private var photoItems: [PhotosPickerItem] = []

    var body: some View {
        VStack {
            PhotosPicker(selection: $photoItems, maxSelectionCount: 5, matching: .images) {
                Text("Select Images")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .onChange(of: photoItems) { _ in
            Task {
                selectedImages.removeAll()
                for item in photoItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
}
