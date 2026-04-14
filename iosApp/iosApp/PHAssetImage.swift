//
//  PHAssetImage.swift
//  iosApp
//
//  Created by SangHwiBack on 4/14/26.
//

import SwiftUI
import Photos

struct PHAssetImage: View {
    let asset: PHAsset
    let size: CGSize
    @State private var image: UIImage?
    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .onDisappear {
                    print("Memory clean works right?")
                    self.image = nil
                }
        } else {
            ProgressView()
                .frame(width: size.width, height: size.height)
                .onAppear {
                    fetchImage(for: asset)
                }
        }
    }
    
    private func fetchImage(for asset: PHAsset) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .fastFormat
        
        manager.requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            self.image = image
        }
    }
}
