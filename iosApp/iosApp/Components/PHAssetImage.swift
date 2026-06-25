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
    let showBackground: Bool

    @State private var status: PHAssetImageStatus = .none
    
    init(asset: PHAsset,
         size: CGSize = thumbnailSize,
         image: UIImage? = nil,
         filter: CIFilter? = nil,
         showBackground: Bool = true,
    ) {
        self.asset = asset
        self.size = size
        self.showBackground = showBackground
        
        if let image {
            self.status = .image(image)
        }
    }
    
    init(assetIdentifier: String,
         size: CGSize = thumbnailSize,
         image: UIImage? = nil,
         filter: CIFilter? = nil,
         showBackground: Bool = true,
    ) {
        self.asset = PHAsset
            .fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
            .firstObject
        self.size = size
        self.showBackground = showBackground
        
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
        
        guard let asset else {
            status = .noImage
            return
        }
        
        Task {
            do {
                if let result = try await PickImageFetcher().loadImageUsingSource(source: asset) {
                    status = .image(result)
                }
                else {
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
