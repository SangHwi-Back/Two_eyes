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

    // 위치·필터 상태 — ViewModel Flow 를 관찰해 동기화
    var leadingState  = PickImageMergeViewModel.ImageState(offsetX: 0, offsetY: 0, scale: 1, filter: nil) {
        didSet { tryRender() }
    }
    var trailingState = PickImageMergeViewModel.ImageState(offsetX: 0, offsetY: 0, scale: 1, filter: nil) {
        didSet { tryRender() }
    }
    var zOrder: [PickImageMergeViewModel.ImageOrder] = [.bottom, .top]

    // 합성에 사용할 원본 이미지 (PHImageManager 로 로드)
    private let imageSourceModel: PickImageMergeModel
    private var leadingImage:  UIImage?
    private var trailingImage: UIImage?

    // CIFilter 처리를 위한 공유 컨텍스트 (생성 비용이 크므로 한 번만 생성)
    private let ciContext = CIContext()

    // 제스처 캔버스 크기 — onAppear 에서 주입
    private var canvasSize: CGSize = .zero

    init(model: PickImageMergeModel) {
        self.imageSourceModel = model

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
                self.trailingImage = _trailingImage
                self.tryRender()
            } catch {
                // TODO: Error Handling Needed
            }
        }

        viewModel.leading.collect(
            collector: MergeCollector<PickImageMergeViewModel.ImageState> { [weak self] state in
                self?.leadingState = state
            }
        ) { _ in }

        viewModel.trailing.collect(
            collector: MergeCollector<PickImageMergeViewModel.ImageState> { [weak self] state in
                self?.trailingState = state
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
                targetSizeWidth: Double(AppConstants.shared.THUMBNAIL_SIZE_WIDTH),
                targetSizeHeight: Double(AppConstants.shared.THUMBNAIL_SIZE_HEIGHT)
            )
    }

    private func tryRender() {
        guard canvasSize.width > 0,
              let leadingImage, let trailingImage else { return }

        // SwiftUI offset (ZStack 중심 기준) → 캔버스 top-left 기준 CGRect 로 변환
        func makeRect(_ state: PickImageMergeViewModel.ImageState) -> CGRect {
            let w = CGFloat(Float(AppConstants.shared.THUMBNAIL_SIZE_WIDTH)  * state.scale)
            let h = CGFloat(Float(AppConstants.shared.THUMBNAIL_SIZE_HEIGHT) * state.scale)
            return CGRect(
                x: canvasSize.width  / 2 + CGFloat(state.offsetX) - w / 2,
                y: canvasSize.height / 2 + CGFloat(state.offsetY) - h / 2,
                width: w, height: h
            )
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
        let filteredBottom = applyFilter(bottomImage, filter: bottomFilter)
        let filteredTop    = applyFilter(topImage,    filter: topFilter)

        mergedImage = renderBlended(
            canvasSize:  canvasSize,
            bottomImage: filteredBottom, bottomRect: bottomRect,
            topImage:    filteredTop,    topRect:    topRect
        )
    }

    /// CIFilter 를 적용해 새 UIImage 반환. filter == nil 이면 원본 그대로.
    private func applyFilter(_ image: UIImage, filter: PickImageMergeViewModel.ImageState.Filter?) -> UIImage {
        guard let filter,
              let ciImage = CIImage(image: image) else { return image }

        let outputCI: CIImage?

        switch filter {
        case .inverted:
            let f = CIFilter(name: "CIColorInvert")!
            f.setValue(ciImage, forKey: kCIInputImageKey)
            outputCI = f.outputImage

        case .monochrome:
            let f = CIFilter(name: "CIPhotoEffectMono")!
            f.setValue(ciImage, forKey: kCIInputImageKey)
            outputCI = f.outputImage

        case .contrast:
            let f = CIFilter(name: "CIColorControls")!
            f.setValue(ciImage, forKey: kCIInputImageKey)
            f.setValue(1.5, forKey: kCIInputContrastKey)
            outputCI = f.outputImage

        case .saturation:
            let f = CIFilter(name: "CIColorControls")!
            f.setValue(ciImage, forKey: kCIInputImageKey)
            f.setValue(2.5, forKey: kCIInputSaturationKey)
            outputCI = f.outputImage

        case .vignette:
            let f = CIFilter(name: "CIVignette")!
            f.setValue(ciImage, forKey: kCIInputImageKey)
            f.setValue(1.5, forKey: kCIInputIntensityKey)
            f.setValue(1.0, forKey: kCIInputRadiusKey)
            outputCI = f.outputImage

        default:
            return image
        }

        guard let out = outputCI,
              let cgImage = ciContext.createCGImage(out, from: ciImage.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    /// 두 이미지를 캔버스에 합성 — 겹치는 영역은 alpha 0.5 blend
    private func renderBlended(
        canvasSize:  CGSize,
        bottomImage: UIImage, bottomRect: CGRect,
        topImage:    UIImage, topRect:    CGRect
    ) -> UIImage {
        UIGraphicsImageRenderer(size: canvasSize).image { ctx in
            let cgCtx = ctx.cgContext

            // 아래 이미지 전체 그리기
            bottomImage.draw(in: bottomRect)

            let intersection = bottomRect.intersection(topRect)

            if intersection.isNull || intersection.isEmpty {
                // 겹침 없음 — 위 이미지 그대로 그리기
                topImage.draw(in: topRect)
                return
            }

            // 겹치지 않는 영역 정상 그리기
            cgCtx.saveGState()
            let clipPath = UIBezierPath(rect: topRect)
            clipPath.append(UIBezierPath(rect: intersection).reversing())
            clipPath.usesEvenOddFillRule = true
            clipPath.addClip()
            topImage.draw(in: topRect)
            cgCtx.restoreGState()

            // 겹치는 영역 blend (alpha 0.5)
            cgCtx.saveGState()
            cgCtx.clip(to: intersection)
            topImage.draw(in: topRect, blendMode: .normal, alpha: 0.5)
            cgCtx.restoreGState()
        }
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
