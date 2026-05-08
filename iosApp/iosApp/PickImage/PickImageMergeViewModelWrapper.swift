//
//  PickImageMergeViewModelWrapper.swift
//  iosApp
//
//  Created by SangHwiBack on 4/14/26.
//

import Foundation
import UIKit
import Photos
import Shared

@Observable
final class PickImageMergeViewModelWrapper {
    let viewModel = PickImageMergeViewModel()
    let imageFetcher = PickImageFetcher()
    var mergedImage: UIImage?

    // 위치 상태 — ViewModel Flow 를 관찰해 동기화
    var leadingState  = PickImageMergeViewModel.ImageState(offsetX: 0, offsetY: 0, scale: 1) {
        didSet { tryRender() }
    }
    var trailingState = PickImageMergeViewModel.ImageState(offsetX: 0, offsetY: 0, scale: 1) {
        didSet { tryRender() }
    }
    var zOrder: [PickImageMergeViewModel.ImageOrder] = [.bottom, .top]

    // 합성에 사용할 원본 이미지 (PHImageManager 로 로드)
    private let imageSourceModel: PickImageMergeModel
    private var leadingImage:  UIImage?
    private var trailingImage: UIImage?

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
        let (bottomImage, bottomRect) = isLeadingBottom
            ? (leadingImage,  leadingRect)
            : (trailingImage, trailingRect)
        let (topImage, topRect) = isLeadingBottom
            ? (trailingImage, trailingRect)
            : (leadingImage,  leadingRect)

        mergedImage = renderBlended(
            canvasSize:  canvasSize,
            bottomImage: bottomImage, bottomRect: bottomRect,
            topImage:    topImage,    topRect:    topRect
        )
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

            // 겹치는 영역 blur blend (alpha 0.5)
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
