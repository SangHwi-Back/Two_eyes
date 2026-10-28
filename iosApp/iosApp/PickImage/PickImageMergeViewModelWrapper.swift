//
//  PickImageMergeViewModelWrapper.swift
//  iosApp
//
//  Created by SangHwiBack on 4/14/26.
//

import Foundation
import UIKit
import Photos
import CoreImage
import Shared

@Observable
final class PickImageMergeViewModelWrapper {
    let viewModel = PickImageMergeViewModel()
    let imageFetcher = PickImageFetcher()
    var mergedImage: UIImage?
    var zOrder: [PickImageMergeViewModel.ImageOrder]
    
    // 위치·필터 상태 — ViewModel Flow 를 관찰해 동기화
    var leadingState: PickImageMergeViewModel.ImageState {
        viewModel.leading.value as! PickImageMergeViewModel.ImageState
    }
    var leadingSize: CGSize {
        CGSize(
            width: Int(Float(leadingImage?.size.width ?? thumbnailWidth) * leadingState.scale),
            height: Int(Float(leadingImage?.size.height ?? thumbnailHeight) * leadingState.scale)
        )
    }
    var trailingState: PickImageMergeViewModel.ImageState {
        viewModel.trailing.value as! PickImageMergeViewModel.ImageState
    }
    var trailingSize: CGSize {
        CGSize(
            width: Int(Float(trailingImage?.size.width ?? thumbnailWidth) * trailingState.scale),
            height: Int(Float(trailingImage?.size.height ?? thumbnailHeight) * trailingState.scale)
        )
    }
    var isLeadingBottom: Bool {
        zOrder.first == .bottom
    }
    
    // 합성에 사용할 원본 이미지 (PHImageManager 로 로드)
    private let imageSourceModel: PickImageMergeModel
    private var leadingImage:  UIImage?
    private var trailingImage: UIImage?
    private var originalLeadingImage:  UIImage?
    private var originalTrailingImage: UIImage?

    // CIFilter 처리를 위한 공유 컨텍스트 (생성 비용이 크므로 한 번만 생성)
    private let applyFilter = PlatformApplyFilter()

    // 제스처 캔버스 크기 — onAppear 에서 주입
    private(set) var canvasSize: CGSize = .zero
    var canvasInt: (width: Int32, height: Int32) {
        (width: Int32(canvasSize.width), height: Int32(canvasSize.height))
    }

    init(model: PickImageMergeModel) {
        self.imageSourceModel = model
        self.zOrder = viewModel.zOrder.value as? [PickImageMergeViewModel.ImageOrder] ?? []

        Task { [weak self] in
            do {
                let images = try await self?.fetchImages(assets: [model.leading, model.trailing])

                guard let self,
                      let _leadingImage = images?.first,
                      let _trailingImage = images?.last
                else {
                    throw NSError(
                        domain: "PickImageFetcher.fetchImages(assets:)",
                        code: -1,
                        userInfo: [
                            "PickImageLeading": model.leading,
                            "PickImageTrailing": model.trailing
                        ])
                }

                self.leadingImage = _leadingImage
                self.originalLeadingImage = _leadingImage
                self.trailingImage = _trailingImage
                self.originalTrailingImage = _trailingImage
                self.tryRender()
            } catch {
                // TODO: Error Handling Needed
            }
        }

        viewModel.leading.collect(
            collector: MergeCollector<PickImageMergeViewModel.ImageState> { [weak self] state in
                self?.tryRender()
            }
        ) { _ in }

        viewModel.trailing.collect(
            collector: MergeCollector<PickImageMergeViewModel.ImageState> { [weak self] state in
                self?.tryRender()
            }
        ) { _ in }
        
        viewModel.zOrder.collect(
            collector: MergeCollector<[PickImageMergeViewModel.ImageOrder]> { [weak self] order in
                self?.zOrder = order
            }
        ) { _ in }
    }

    /// GeometryReader 에서 얻은 캔버스 크기를 전달 — 크기가 바뀔 때만 재렌더
    func setCanvasSize(_ size: CGSize) {
        guard size != canvasSize, size.width > 0 else { return }
        canvasSize = size
        tryRender()
    }

    // MARK: - Private

    private func fetchImages(assets: [PHAsset]) async throws -> [UIImage] {
        try await imageFetcher.convertToUIImages(
                assets: assets,
                targetSizeWidth: Double(thumbnailWidth),
                targetSizeHeight: Double(thumbnailHeight)
            )
    }
    
    func setLeadingStateValue(_ value: MergeImagePropertyTransferType) {
        setStateValue(true, value: value)
    }
    func setTrailingStateValue(_ value: MergeImagePropertyTransferType) {
        setStateValue(false, value: value)
    }
    
    private func setStateValue(_ isLeading: Bool, value: MergeImagePropertyTransferType) {
        let base = isLeading ? leadingState : trailingState
        let newValue: PickImageMergeViewModel.ImageState = {
            switch value {
            case .filter(let imageStateFilter):
                return PickImageMergeViewModel.ImageState(
                    offsetX: base.offsetX,
                    offsetY: base.offsetY,
                    scale: base.scale,
                    filter: imageStateFilter)
            case .offset(let cGSize):
                return PickImageMergeViewModel.ImageState(
                    offsetX: Float(cGSize.width),
                    offsetY: Float(cGSize.height),
                    scale: base.scale,
                    filter: base.filter)
            case .scale(let scale):
                return PickImageMergeViewModel.ImageState(
                    offsetX: base.offsetX,
                    offsetY: base.offsetY,
                    scale: scale,
                    filter: base.filter)
            }
        }()
        
        if isLeading {
            viewModel.updateLeading(imageState: newValue)
        } else {
            viewModel.updateTrailing(imageState: newValue)
        }
    }
    
    private func tryRender() {
        guard canvasSize.width > 0, let renderingModel = getRenderingModel() else {
            return
        }
        
        mergedImage = ImageMerger().merge(canvasSize: canvasSize, model: renderingModel)
    }
    
    private func getRenderingModel() -> RenderingImageModel? {
        guard
            let bottomImage = getBottomFilteredImage(),
            let topImage = getTopFilteredImage()
        else {
            return nil
        }
        
        return RenderingImageModel(
            bottomRect: getBottomImageRect(),
            topRect: getTopImageRect(),
            bottomImage: bottomImage,
            topImage: topImage
        )
    }
    
    private func getBottomFilteredImage() -> UIImage? {
        getFilteredImage(isLeading: isLeadingBottom)
    }
    
    private func getTopFilteredImage() -> UIImage? {
        getFilteredImage(isLeading: !isLeadingBottom)
    }
    
    private func getFilteredImage(isLeading: Bool) -> UIImage? {
        if isLeading {
            guard let leadingImage else {
                return originalLeadingImage
            }
            return applyFilter.appleApplyFilter(image: leadingImage, filter: leadingState.filter)
        }
        else {
            guard let trailingImage else {
                return originalTrailingImage
            }
            return applyFilter.appleApplyFilter(image: trailingImage, filter: trailingState.filter)
        }
    }
    
    private func getBottomImageRect() -> CGRect {
        createImageRect(isLeading: isLeadingBottom)
    }
    
    private func getTopImageRect() -> CGRect {
        createImageRect(isLeading: !isLeadingBottom)
    }
    
    private func createImageRect(isLeading: Bool) -> CGRect {
        CGRect(
            origin: isLeading ? leadingState.getCGPoint : trailingState.getCGPoint,
            size: isLeading ? leadingSize : trailingSize
        )
    }
    
    func mergeDone(dao: MergeResultDao) -> Bool {
        guard let mergedImage else {
            return false
        }

        viewModel.saveMergedImage(
            dao: dao,
            mergedImage: mergedImage,
            leadingImageId: imageSourceModel.leading.localIdentifier,
            trailingImageId: imageSourceModel.trailing.localIdentifier,
            name: "Testing")

        return true
    }
}

// MARK: - Collector (KMP Flow → Swift 브릿지)

class MergeCollector<T>: Kotlinx_coroutines_coreFlowCollector {
    let callback: (T) -> Void
    init(callback: @escaping (T) -> Void) { self.callback = callback }
    func emit(value: Any?, completionHandler: @escaping (Error?) -> Void) {
        if let value = value as? T {
            callback(value)
            completionHandler(nil)
        } else {
            completionHandler(CollectorError.invalidValue)
        }
    }
}

struct RenderingImageModel {
    let bottomRect: CGRect
    let topRect: CGRect
    let bottomImage: UIImage
    let topImage: UIImage
}

enum CollectorError: Error {
    case invalidValue
}

enum MergeImagePropertyTransferType {
    case filter(PickImageMergeViewModel.ImageStateFilter?)
    case offset(CGSize)
    case scale(Float)
}

private extension PickImageMergeViewModel.ImageState {
    var getCGPoint: CGPoint {
        CGPoint(x: CGFloat(offsetX), y: CGFloat(offsetY))
    }
}
private extension ImageMerger {
    func merge(canvasSize: CGSize, model: RenderingImageModel) -> UIImage? {
        merge(model: getImageMergerModel(
            canvasSize: canvasSize,
            bottomImage: model.bottomImage,
            bottomRect: model.bottomRect,
            topImage: model.topImage,
            topRect: model.topRect
        ))
    }
    
    func getImageMergerModel(
        canvasSize: CGSize,
        bottomImage: UIImage, bottomRect: CGRect,
        topImage: UIImage, topRect: CGRect
    ) -> ImageMergerModel {
        ImageMergerModel(
            canvasWidth: Int32(canvasSize.width),
            canvasHeight: Int32(canvasSize.height),
            bottomImage: ImageMergerModel.ImageInfo(
                image: bottomImage,
                frame: getImageFrame(bottomRect)
            ),
            topImage: ImageMergerModel.ImageInfo(
                image: topImage,
                frame: getImageFrame(topRect)
            ),
            blendAlpha: 0.5
        )
    }
    
    func getImageFrame(_ rect: CGRect) -> ImageFrame {
        ImageFrame(
            left: Float(rect.origin.x),
            top: Float(rect.origin.y),
            right: Float(rect.origin.x + rect.size.width),
            bottom: Float(rect.origin.y + rect.size.height)
        )
    }
}
