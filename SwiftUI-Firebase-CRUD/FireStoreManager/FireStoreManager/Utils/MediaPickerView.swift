//
//  MediaPickerView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 04/03/25.
//

import SwiftUI
import PhotosUI
import AVKit

struct MediaPickerView: View {
    @State private var selectedPhotoItems: [PhotosPickerItem] = [] // ✅ Store selected PhotosPickerItems
    @State private var selectedImages: [UIImage] = [] // ✅ Store converted images
    @State private var selectedVideoURL: URL? = nil // ✅ Store selected video URL
    @State private var isPickerPresented = false

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                    }

                    if let videoURL = selectedVideoURL {
                        VideoThumbnailView(videoURL: videoURL)
                            .frame(width: 100, height: 100)
                    }
                }
            }
            .padding()

            Button("Select Media") {
                isPickerPresented.toggle()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .photosPicker(
            isPresented: $isPickerPresented,
            selection: $selectedPhotoItems, // ✅ Corrected Binding
            maxSelectionCount: 5,
            matching: .any(of: [.images, .videos]) // ✅ Allow images & videos
        )
        .onChange(of: selectedPhotoItems) { newItems in
            Task {
                await loadSelectedMedia(from: newItems)
            }
        }
    }

    // Convert PhotosPickerItem to UIImage or Video URL
    private func loadSelectedMedia(from items: [PhotosPickerItem]) async {
        selectedImages.removeAll()
        selectedVideoURL = nil
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImages.append(image)
            } else if let videoData = try? await item.loadTransferable(type: URL.self) {
                selectedVideoURL = videoData
            }
        }
    }
}

