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
        let (leadingSize, trailingSize): (CGSize, CGSize) = (
            thumbnailSize * CGFloat(wrapper.leadingState.scale),
            thumbnailSize * CGFloat(wrapper.trailingState.scale)
        )
        let (leadingZIndex, trailingZIndex): (Double, Double) = (
            wrapper.zOrder.first == .top ? 999 : 1000,
            wrapper.zOrder.last == .top ? 999 : 1000,
        )
        let cornerRadius = CGFloat(constant.CARD_CORNER_RADIUS)
        
        GeometryReader { proxy in
            // GeometryReader 는 자식을 모두 (0,0) 에 쌓으므로 VStack 으로 감쌈
            VStack(spacing: 0) {
                ZStack {
                    PHAssetImage(asset: leadingSource, size: leadingSize)
                        .draggableAndScalable($wrapper.leadingState)
                        .zIndex(leadingZIndex)

                    PHAssetImage(asset: trailingSource, size: trailingSize)
                        .draggableAndScalable($wrapper.trailingState)
                        .zIndex(trailingZIndex)

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
                    let centerOffsetXDetached = Float(proxy.size.width) / 4
                    wrapper.setCanvasSize(proxy.canvasSize)

                    // ViewModel 초기 상태 동기화
                    wrapper.leadingState = .init(
                        offsetX: -centerOffsetXDetached, offsetY: 0, scale: 1, filter: nil)
                    wrapper.trailingState = .init(
                        offsetX:  centerOffsetXDetached, offsetY: 0, scale: 1, filter: nil)
                }

                Divider()
                    .padding(.vertical)

                ZStack(alignment: .center) {
                    // Rectangle().background() 는 흰색 fill 이 아닌 배경 레이어이므로 fill + stroke 로 수정
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(AppColors.shared.Surface.color)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(AppColors.shared.Surface2.color, lineWidth: 1)
                        )

                    if let image = $wrapper.mergedImage.wrappedValue {
                        Image(uiImage: image)
                            .resizable()
                            .frame(maxWidth: proxy.size.width, maxHeight: proxy.size.width * 0.75)
                            .aspectRatio(CGFloat(constant.THUMBNAIL_ASPECT_RATIO), contentMode: .fit)
                            .padding(.vertical)
                    } else {
                        ProgressView().frame(
                            width: CGFloat(AppConstants.shared.ICON_SIZE_WIDTH),
                            height: CGFloat(AppConstants.shared.ICON_SIZE_HEIGHT))
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
                                scale: base.scale,
                                filter: nil
                            )
                        }
                        .onEnded { value in
                            guard let base = baseState else { return }
                            imageState = .init(
                                offsetX: base.offsetX + Float(value.translation.width),
                                offsetY: base.offsetY + Float(value.translation.height),
                                scale: base.scale,
                                filter: nil
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
                                scale: base.scale * Float(value.magnification),
                                filter: nil
                            )
                        }
                        .onEnded { value in
                            guard let base = baseState else { return }
                            imageState = .init(
                                offsetX: base.offsetX,
                                offsetY: base.offsetY,
                                scale: base.scale * Float(value.magnification),
                                filter: nil
                            )
                            baseState = nil
                        }
                )
        }
    }
}

