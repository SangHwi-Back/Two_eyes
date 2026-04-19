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
    @State private var requestID: PHImageRequestID?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
            } else {
                ProgressView()
                    .frame(width: size.width, height: size.height)
            }
        }
        .onAppear {
            fetchImage()
        }
        .onDisappear {
            cancelAndClear()
        }
    }

    private func fetchImage() {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat

        requestID = PHImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        ) { result, _ in
            self.image = result
        }
    }

    private func cancelAndClear() {
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
            requestID = nil
        }
        image = nil
    }
}
