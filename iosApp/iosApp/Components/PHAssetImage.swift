//
//  PHAssetImage.swift
//  iosApp
//
//  Created by SangHwiBack on 4/14/26.
//

import SwiftUI
import Photos
import Shared

struct PHAssetImage: View {
    let asset: PHAsset?
    let size: CGSize

    @State private var image: UIImage?
    @State private var requestID: PHImageRequestID?
    @State private var error: NSError?
    
    init(asset: PHAsset,
         size: CGSize = thumbnailSize,
         image: UIImage? = nil,
         requestID: PHImageRequestID? = nil,
         filter: CIFilter? = nil,
    ) {
        self.asset = asset
        self.size = size
        self.image = image
        self.requestID = requestID
    }
    
    init(assetIdentifier: String,
         size: CGSize = thumbnailSize,
         image: UIImage? = nil,
         requestID: PHImageRequestID? = nil,
         filter: CIFilter? = nil,
    ) {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
        
        if let asset = fetchResult.firstObject {
            // Successfully retrieved the PHAsset
            self.asset = asset
        } else {
            self.asset = nil
        }
        
        self.size = size
        self.image = image
        self.requestID = requestID
    }

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.shared.Surface2.color)
                    .stroke(.gray, style: StrokeStyle(lineWidth: 1))
                    .frame(width: size.width, height: size.height)
                
                if error == nil {
                    ProgressView()
                        .frame(width: 52, height: 52)
                } else {
                    Circle()
                        .fill(Color.white)
                        .stroke(AppColors.shared.Divider.color,
                                style: StrokeStyle(lineWidth: 1))
                        .frame(width: 52, height: 52, alignment: .center)
                    
                    Image(systemName: "xmark")
                        .frame(width: 32, height: 32, alignment: .center)
                        .foregroundStyle(AppColors.shared.Accent.color)
                }
            }
        }
        .onAppear {
            fetchImage()
        }
        .onChange(of: asset) {
            // asset 프로퍼티가 교체되면 onAppear 는 재호출되지 않으므로
            // 직접 감지해서 이전 요청을 취소하고 새 이미지를 fetch 합니다.
            cancelAndClear()
            fetchImage()
        }
        .onDisappear {
            cancelAndClear()
        }
    }

    private func fetchImage() {
        guard let asset else {
            error = NSError()
            return
        }
        
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat

        requestID = PHImageManager.default().requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFill,
            options: options
        ) { result, info in
            if let error = info?[PHImageErrorKey] as? NSError {
                self.error = error
            }
            self.image = result
        }
    }

    private func cancelAndClear() {
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
            requestID = nil
        }
        image = nil
        error = nil
    }
}
