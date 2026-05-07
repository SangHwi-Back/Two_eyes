//
//  PickImageMergeView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/13/26.
//

import SwiftUI
import Photos
import Shared

struct PickImageMergeView: View {
    // @Observable 클래스는 @State 로 관리해야 부모 뷰 재생성 시 재초기화되지 않음
    @State private var wrapper: PickImageMergeViewModelWrapper
    
    @State private var mergeDoneAlert = false
    
    @EnvironmentObject var navHost: NavigationPathObject<NavHost.Camera>
    @Environment(\.mergeResultDao) var dao
    @Environment(\.appConstant) var constant

    let bottomZIndex: Double = 999
    let topZIndex: Double = 1000
    let leadingSource: PHAsset
    let trailingSource: PHAsset

    init(model: PickImageMergeModel) {
        self._wrapper = State(initialValue: PickImageMergeViewModelWrapper(model: model))
        self.leadingSource = model.leading
        self.trailingSource = model.trailing
    }

    var body: some View {
        let thumbnailSize: CGSize = CGSize(
            width: CGFloat(constant.THUMBNAIL_SIZE_WIDTH),
            height: CGFloat(constant.THUMBNAIL_SIZE_HEIGHT)
        )
        GeometryReader { proxy in
            // GeometryReader 는 자식을 모두 (0,0) 에 쌓으므로 VStack 으로 감쌈
            VStack(spacing: 0) {
                ZStack {
                    PHAssetImage(asset: leadingSource, size: thumbnailSize * CGFloat(wrapper.leadingState.scale))
                        .draggableAndScalable($wrapper.leadingState)
                        .zIndex(bottomZIndex)

                    PHAssetImage(asset: trailingSource, size: thumbnailSize * CGFloat(wrapper.trailingState.scale))
                        .draggableAndScalable($wrapper.trailingState)
                        .zIndex(topZIndex)

                    GlassIconButton(systemName: "arrow.left.arrow.right") {
                        wrapper.viewModel.swapOrder()
                    }
                    .offset(
                        x: (proxy.canvasSize.width / 2) - 20 - 10,
                        y: (proxy.canvasSize.height / -2) - 20 - 10
                    )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .onAppear {
                    let canvasSize = CGSize(width: proxy.size.width, height: 300)
                    wrapper.setCanvasSize(canvasSize)

                    // ViewModel 초기 상태 동기화
                    wrapper.leadingState = .init(
                        offsetX: -Float(proxy.size.width) / 4, offsetY: 0, scale: 1)
                    wrapper.trailingState = .init(
                        offsetX:  Float(proxy.size.width) / 4, offsetY: 0, scale: 1)
                }

                Divider()
                    .padding(.vertical)

                ZStack(alignment: .center) {
                    // Rectangle().background() 는 흰색 fill 이 아닌 배경 레이어이므로 fill + stroke 로 수정
                    RoundedRectangle(cornerRadius: CGFloat(constant.CARD_CORNER_RADIUS))
                        .fill(AppColors.shared.Surface.color)
                        .overlay(
                            RoundedRectangle(cornerRadius: CGFloat(constant.CARD_CORNER_RADIUS))
                                .stroke(AppColors.shared.Surface2.color, lineWidth: 1)
                        )

                    if let image = $wrapper.mergedImage.wrappedValue {
                        Image(uiImage: image)
                            .resizable()
                            .frame(maxWidth: proxy.size.width, maxHeight: proxy.size.width * 0.75)
                            .aspectRatio(CGFloat(constant.THUMBNAIL_ASPECT_RATIO), contentMode: .fit)
                            .padding(.vertical)
                    } else {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: proxy.size.width * 0.75)
                .padding(.bottom)
                
                HStack {
                    Spacer()
                    GlassIconButton(systemName: "checkmark.circle") {
                        let isSuccess = wrapper.mergeDone(dao: dao)
                        
                        if isSuccess {
                            navHost.popToRoot()
                        } else {
                            mergeDoneAlert = true
                        }
                    }
                }
            }
        }
        .alert("경고!", isPresented: $mergeDoneAlert) {
            Button("확인", role: .confirm) {}
        } message: {
            Text("이미지 결과에 이상이 발생하였습니다.")
        }
    }
}

private extension PickImageMergeViewModel.ImageState {
    var offset: CGSize {
        CGSize(width: CGFloat(offsetX), height: CGFloat(offsetY))
    }
}

private extension GeometryProxy {
    var canvasSize: CGSize {
        CGSize(width: size.width, height: 300)
    }
}

// MARK: - Gesture Modifier

private extension PHAssetImage {
    /// 드래그(위치 누적) + 핀치 줌을 동시에 지원하는 modifier
    func draggableAndScalable(_ state: Binding<PickImageMergeViewModel.ImageState>) -> some View {
        self.modifier(DraggableScalableModifier(imageState: state))
    }

    struct DraggableScalableModifier: ViewModifier {
        // 제스처 시작 시점의 상태를 캡처해두는 base — onChanged마다 base + delta 로 계산
        @State private var baseState: PickImageMergeViewModel.ImageState?

        @Binding var imageState: PickImageMergeViewModel.ImageState

        func body(content: Content) -> some View {
            content
                .scaleEffect(CGFloat(imageState.scale))
                .offset(x: CGFloat(imageState.offsetX), y: CGFloat(imageState.offsetY))
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            if baseState == nil { baseState = imageState }
                            guard let base = baseState else { return }
                            imageState = .init(
                                offsetX: base.offsetX + Float(value.translation.width),
                                offsetY: base.offsetY + Float(value.translation.height),
                                scale: base.scale
                            )
                        }
                        .onEnded { value in
                            guard let base = baseState else { return }
                            imageState = .init(
                                offsetX: base.offsetX + Float(value.translation.width),
                                offsetY: base.offsetY + Float(value.translation.height),
                                scale: base.scale
                            )
                            baseState = nil
                        }
                )
                .simultaneousGesture(
                    MagnifyGesture()
                        .onChanged { value in
                            if baseState == nil { baseState = imageState }
                            guard let base = baseState else { return }
                            imageState = .init(
                                offsetX: base.offsetX,
                                offsetY: base.offsetY,
                                scale: base.scale * Float(value.magnification)
                            )
                        }
                        .onEnded { value in
                            guard let base = baseState else { return }
                            imageState = .init(
                                offsetX: base.offsetX,
                                offsetY: base.offsetY,
                                scale: base.scale * Float(value.magnification)
                            )
                            baseState = nil
                        }
                )
        }
    }
}

