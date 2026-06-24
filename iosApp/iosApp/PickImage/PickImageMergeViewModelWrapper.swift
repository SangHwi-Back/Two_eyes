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
    var trailingState: PickImageMergeViewModel.ImageState {
        viewModel.trailing.value as! PickImageMergeViewModel.ImageState
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
        guard canvasSize.width > 0,
              let leadingImage, let originalLeadingImage, let trailingImage, let originalTrailingImage else { return }

        // SwiftUI offset (ZStack 중심 기준) → 캔버스 top-left 기준 CGRect 로 변환
        func makeRect(_ state: PickImageMergeViewModel.ImageState) -> CGRect {
            CGRect(
                x: CGFloat(state.offsetX),
                y: CGFloat(state.offsetY),
                width: thumbnailWidth * CGFloat(state.scale),
                height: thumbnailHeight * CGFloat(state.scale))
        }

        let leadingRect  = makeRect(leadingState)
        let trailingRect = makeRect(trailingState)

        let isLeadingBottom = zOrder.first == .bottom
        let (bottomImage, bottomRect, bottomFilter) = isLeadingBottom
            ? (leadingImage,  leadingRect,  leadingState.filter)
            : (trailingImage, trailingRect, trailingState.filter)
        let (topImage, topRect, topFilter) = isLeadingBottom
            ? (trailingImage, trailingRect, trailingState.filter)
            : (leadingImage,  leadingRect,  leadingState.filter)

        // 필터 적용 후 합성
        let filteredBottom = (bottomFilter == nil)
        ? (isLeadingBottom ? originalLeadingImage : originalTrailingImage)
        : applyFilter.appleApplyFilter(
            image: bottomImage, filter: bottomFilter)
        let filteredTop    = (topFilter == nil)
        ? (isLeadingBottom ? originalTrailingImage : originalLeadingImage)
        : applyFilter.appleApplyFilter(
            image: topImage, filter: topFilter)
        
        mergedImage = ImageMerger()
            .merge(model: getImageMergerModel(
                bottomImage: bottomImage, bottomRect: bottomRect,
                topImage: topImage, topRect: topRect
            ))
    }
    
    private func getImageMergerModel(
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
    
    private func getImageFrame(_ rect: CGRect) -> ImageFrame {
        ImageFrame(
            left: Float(rect.origin.x),
            top: Float(rect.origin.y),
            right: Float(rect.origin.x + rect.size.width),
            bottom: Float(rect.origin.y + rect.size.height)
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

enum CollectorError: Error {
    case invalidValue
}

enum MergeImagePropertyTransferType {
    case filter(PickImageMergeViewModel.ImageStateFilter?)
    case offset(CGSize)
    case scale(Float)
}
