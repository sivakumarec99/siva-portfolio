//
//  VideoThumbnailView.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 04/03/25.
//

import Foundation
import SwiftUI
import AVKit

struct VideoThumbnailView: View {
    let videoURL: URL

    var body: some View {
        ZStack {
            VideoPlayer(player: AVPlayer(url: videoURL))
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
                .shadow(radius: 4)
        }
    }
}
