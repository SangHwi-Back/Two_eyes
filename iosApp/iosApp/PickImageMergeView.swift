//
//  PickImageMergeView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/13/26.
//

import SwiftUI

struct PickImageMergeView: View {
    let model: PickImageMergeModel
    // @Observable 클래스는 @State 로 관리해야 부모 뷰 재생성 시 재초기화되지 않음
    @State private var wrapper: PickImageMergeViewModelWrapper

    let bottomZIndex: Double = 999
    let topZIndex: Double = 1000

    private let thumbnailSize: CGSize = CGSize(width: 120, height: 190)

    // @GestureState 는 제스처 종료 시 리셋되므로 누적 위치는 @State 로 관리
    @State private var leadingOffset: CGSize = .zero
    @State private var leadingScale: CGFloat = 1.0
    @State private var trailingOffset: CGSize = .zero   // onAppear 에서 오른쪽 끝으로 설정
    @State private var trailingScale: CGFloat = 1.0

    init(model: PickImageMergeModel) {
        self.model = model
        self._wrapper = State(initialValue: PickImageMergeViewModelWrapper(model: model))
    }

    var body: some View {
        GeometryReader { proxy in
            // GeometryReader 는 자식을 모두 (0,0) 에 쌓으므로 VStack 으로 감쌈
            VStack(spacing: 0) {
                ZStack {
                    PHAssetImage(asset: model.leading, size: thumbnailSize)
                        .draggableAndScalable(
                            offset: $leadingOffset,
                            scale: $leadingScale,
                            onUpdate: { offset, _ in
                                wrapper.viewModel.updatePosition(
                                    order: .bottom,
                                    x: Float(offset.width),
                                    y: Float(offset.height))
                            }
                        )
                        .zIndex(bottomZIndex)

                    PHAssetImage(asset: model.trailing, size: thumbnailSize)
                        .draggableAndScalable(
                            offset: $trailingOffset,
                            scale: $trailingScale,
                            onUpdate: { offset, _ in
                                wrapper.viewModel.updatePosition(
                                    order: .top,
                                    x: Float(offset.width),
                                    y: Float(offset.height))
                            }
                        )
                        .zIndex(topZIndex)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .onAppear {
                    // trailing 초기 위치: 오른쪽 끝
                    trailingOffset = CGSize(width: proxy.size.width - thumbnailSize.width, height: 0)
                }

                Divider()
                    .padding(.vertical)

                ZStack(alignment: .center) {
                    // Rectangle().background() 는 흰색 fill 이 아닌 배경 레이어이므로 fill + stroke 로 수정
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )

                    if let image = wrapper.mergedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(1.6, contentMode: .fit)
                            .padding(.vertical)
                    } else {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: proxy.size.width * 0.75)
                .padding(.bottom)
            }
        }
    }
}

private extension GeometryProxy {
    var canvasSize: CGSize {
        CGSize(width: size.width, height: size.width * 1.6)
    }
}

// MARK: - Gesture Modifier

private extension PHAssetImage {
    /// 드래그(위치 누적) + 핀치 줌을 동시에 지원하는 modifier
    func draggableAndScalable(
        offset: Binding<CGSize>,
        scale: Binding<CGFloat>,
        onUpdate: @escaping (CGSize, CGFloat) -> Void
    ) -> some View {
        self.modifier(DraggableScalableModifier(
            accumulatedOffset: offset,
            accumulatedScale: scale,
            onUpdate: onUpdate
        ))
    }

    struct DraggableScalableModifier: ViewModifier {
        // 현재 제스처 중의 임시 델타 (제스처 종료 시 자동 리셋)
        @GestureState private var dragDelta: CGSize = .zero
        @GestureState private var magnificationDelta: CGFloat = 1.0

        // 누적 값 (제스처 종료 후에도 유지)
        @Binding var accumulatedOffset: CGSize
        @Binding var accumulatedScale: CGFloat

        let onUpdate: (CGSize, CGFloat) -> Void

        func body(content: Content) -> some View {
            let currentOffset = CGSize(
                width: accumulatedOffset.width + dragDelta.width,
                height: accumulatedOffset.height + dragDelta.height
            )
            let currentScale = accumulatedScale * magnificationDelta

            content
                .scaleEffect(currentScale)  // 핀치 줌 시각 적용
                .offset(currentOffset)       // 드래그 위치 시각 적용
                .simultaneousGesture(
                    DragGesture()
                        .updating($dragDelta) { value, state, _ in
                            state = value.translation
                            onUpdate(
                                CGSize(
                                    width: accumulatedOffset.width + value.translation.width,
                                    height: accumulatedOffset.height + value.translation.height
                                ),
                                accumulatedScale * magnificationDelta
                            )
                        }
                        .onEnded { value in
                            accumulatedOffset = CGSize(
                                width: accumulatedOffset.width + value.translation.width,
                                height: accumulatedOffset.height + value.translation.height
                            )
                            onUpdate(accumulatedOffset, accumulatedScale)
                        }
                )
                .simultaneousGesture(
                    MagnifyGesture()
                        .updating($magnificationDelta) { value, state, _ in
                            state = value.magnification
                            onUpdate(
                                CGSize(
                                    width: accumulatedOffset.width + dragDelta.width,
                                    height: accumulatedOffset.height + dragDelta.height
                                ),
                                accumulatedScale * value.magnification
                            )
                        }
                        .onEnded { value in
                            accumulatedScale *= value.magnification
                            onUpdate(accumulatedOffset, accumulatedScale)
                        }
                )
        }
    }
}
