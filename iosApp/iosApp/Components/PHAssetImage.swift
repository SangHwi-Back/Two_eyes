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
    // PHAsset 직접 전달 경로
    private let preloadedAsset: PHAsset?
    // assetIdentifier 경로 — init 에서 fetchAssets 를 호출하지 않고 lazy 처리
    private let assetIdentifier: String?

    let size: CGSize
    let showBackground: Bool

    @State private var status: PHAssetImageStatus = .none
    
    init(asset: PHAsset,
         size: CGSize = thumbnailSize,
         image: UIImage? = nil,
         showBackground: Bool = true
    ) {
        self.preloadedAsset  = asset
        self.assetIdentifier = nil
        self.size            = size
        self.showBackground  = showBackground
        if let image {
            self.status = .image(image)
        }
    }
    
    /// assetIdentifier 로 생성할 때는 init 에서 PHAsset.fetchAssets 를 호출하지 않음.
    /// fetchAssets 는 권한이 미확정이면 시스템 알럿을 트리거하므로,
    /// 권한 확인 후 fetchImage() 내부에서 비동기로 처리한다.
    init(assetIdentifier: String,
         size: CGSize = thumbnailSize,
         image: UIImage? = nil,
         showBackground: Bool = true
    ) {
        self.preloadedAsset  = nil
        self.assetIdentifier = assetIdentifier
        self.size            = size
        self.showBackground  = showBackground
        if let image {
            self.status = .image(image)
        }
    }
    
    var body: some View {
        ZStack {
            if showBackground {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.shared.Surface2.color)
                    .stroke(.gray, style: StrokeStyle(lineWidth: 1))
                    .frame(width: size.width, height: size.height)
            }

            switch status {
            case .error(let error):
                Button { fetchImage() } label: {
                    VStack {
                        CircleImage("xmark")
                        ButtonTitle(error.localizedDescription)
                    }
                }
            case .noImage:
                Button { fetchImage() } label: {
                    VStack {
                        CircleImage("questionmark.square.dashed")
                        ButtonTitle("No Image")
                    }
                }
            case .loading:
                ProgressView()
                    .frame(width: 52, height: 52)
            case .image(let uIImage):
                Image(uiImage: uIImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
            case .none:
                EmptyView()
            }
        }
        .task {
            if case .image(_) = status {
                return
            }
            fetchImage()
        }
        .onChange(of: preloadedAsset) {
            cancelAndClear()
            fetchImage()
        }
        .onDisappear {
            cancelAndClear()
        }
    }
    
    // MARK: - Private helpers
    
    @ViewBuilder
    func CircleImage(_ imageName: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .stroke(AppColors.shared.Divider.color,
                        style: StrokeStyle(lineWidth: 1))
                .frame(width: 52, height: 52, alignment: .center)
            Image(systemName: imageName)
                .scaledToFit()
                .foregroundStyle(AppColors.shared.Accent.color)
        }
    }
    
    func ButtonTitle(_ title: String) -> some View {
        Text(title)
            .font(.callout)
            .foregroundStyle(AppColors.shared.TextSecondary.color)
            .lineLimit(2)
    }
    
    private func fetchImage() {
        status = .loading
        
        Task {
            // assetIdentifier 경로: 권한 확인 후 fetchAssets 수행
            let resolvedAsset: PHAsset?
            if let preloaded = preloadedAsset {
                resolvedAsset = preloaded
            } else if let id = assetIdentifier {
                let authStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                guard authStatus == .authorized else {
                    status = .noImage
                    return
                }
                resolvedAsset = PHAsset
                    .fetchAssets(withLocalIdentifiers: [id], options: nil)
                    .firstObject
            } else {
                status = .noImage
                return
            }
            
            guard let resolvedAsset else {
                status = .noImage
                return
            }
            
            do {
                if let result = try await PickImageFetcher().loadImageUsingSource(source: resolvedAsset) {
                    status = .image(result)
                } else {
                    status = .noImage
                }
            } catch {
                status = .error(error)
            }
        }
    }

    private func cancelAndClear() {
        status = .none
    }
    
    enum PHAssetImageStatus {
        case error(any Error)
        case loading
        case image(UIImage)
        case noImage
        case none
    }
}
