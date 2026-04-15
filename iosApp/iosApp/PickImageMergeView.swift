//
//  PickImageMergeView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/13/26.
//

import SwiftUI

struct PickImageMergeView: View {
    let model: PickImageMergeModel
    let wrapper: PickImageMergeViewModelWrapper
    
    let bottomZIndex: Double = 999
    let topZIndex: Double = 1000
    
    private let thumbnailSize: CGSize = CGSize(width: 120, height: 190)
    
    @GestureState private var leadingOffset: CGSize = .zero
    @GestureState private var trailingOffset: CGSize = .init(width: 160, height: 0)
    @GestureState private var leadingMagnification: CGFloat = 1.0
    @GestureState private var trailingMagnification: CGFloat = 1.0
    
    init(model: PickImageMergeModel) {
        self.model = model
        self.wrapper = .init(model: model)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                PHAssetImage(asset: model.leading, size: thumbnailSize)
                    .gesture(
                        offset: $leadingOffset,
                        magnification: $leadingMagnification,
                        onUpdate: { offset, magnification in
                            wrapper.viewModel.updatePosition(
                                order: .bottom,
                                x: Float(offset.width),
                                y: Float(offset.height))
                        },
                        canvasSize: proxy.canvasSize
                    )
                    .offset(CGSize(width: 0, height: 0))
                    .zIndex(bottomZIndex)
                
                PHAssetImage(asset: model.trailing, size: thumbnailSize)
                    .gesture(
                        offset: $trailingOffset,
                        magnification: $trailingMagnification,
                        onUpdate: { offset, magnification in
                            wrapper.viewModel.updatePosition(
                                order: .top,
                                x: Float(offset.width),
                                y: Float(offset.height))
                        },
                        canvasSize: proxy.canvasSize
                    )
                    .offset(CGSize(width: proxy.size.width - thumbnailSize.width, height: 0))
                    .zIndex(topZIndex)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            
            Divider()
                .padding(.vertical)
            
            ZStack(alignment: .center) {
                Rectangle()
                    .background(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .border(Color.gray, width: 1)
                
                if let image = wrapper.mergedImage {
                    Image(uiImage: image)
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

private extension GeometryProxy {
    var canvasSize: CGSize {
        CGSize(width: size.width, height: size.width * 1.6)
    }
}

private extension PHAssetImage {
    func gesture(
        offset: GestureState<CGSize>,
        magnification: GestureState<CGFloat>,
        onUpdate: @escaping (CGSize, CGFloat) -> Void,
        onEnded: ((CGSize, CGFloat) -> Void)? = nil,
        canvasSize: CGSize
    ) -> some View {
        self.modifier(PHAsssetImageGestureModifier(
            offset: offset,
            magnification: magnification,
            onUpdate: onUpdate,
            onEnded: onEnded ?? onUpdate,
            canvasSize: canvasSize
        ))
    }
    
    struct PHAsssetImageGestureModifier: ViewModifier {
        
        @GestureState private var offset: CGSize
        @GestureState private var magnification: CGFloat
        @State private var lastMagnification: CGFloat = 1.0
        
        let canvasSize: CGSize
        
        let onUpdate: (CGSize, CGFloat) -> Void
        let onEnded: (CGSize, CGFloat) -> Void
        
        public init(
            offset: GestureState<CGSize>,
            magnification: GestureState<CGFloat>,
            onUpdate: @escaping (CGSize, CGFloat) -> Void,
            onEnded: @escaping (CGSize, CGFloat) -> Void,
            canvasSize: CGSize
        ) {
            self._offset = offset
            self._magnification = magnification
            self.onUpdate = onUpdate
            self.onEnded = onEnded
            self.canvasSize = canvasSize
        }
        
        func body(content: Content) -> some View {
            content.gesture(
                DragGesture()
                    .updating($offset) { value, state, transaction in
                        state = value.translation
                        onUpdate(state, magnification)
                    }
                    .onEnded { value in
                        onEnded(value.translation, magnification)
                    }
                    .exclusively(before: MagnifyGesture()
                        .updating($magnification) { value, state, transaction in
                            state = value.magnification
                            onUpdate(offset, state)
                        }
                        .onEnded { value in
                            onEnded(offset, value.magnification)
                        }
                    )
            )
        }
    }
}
