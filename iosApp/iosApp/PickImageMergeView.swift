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
    
    private let thumbnailSize: CGSize = CGSize(width: 120, height: 190)
    
    @State private var leadingOffset: CGSize = .zero
    @State private var trailingOffset: CGSize = .init(width: 160, height: 0)
    @State private var leadingMagnification: CGFloat = 1.0
    @State private var trailingMagnification: CGFloat = 1.0
    
    init(model: PickImageMergeModel) {
        self.model = model
        self.wrapper = .init(model: model)
    }
    
    var body: some View {
        GeometryReader { proxy in
            HStack {
                PHAssetImage(asset: model.leading, size: thumbnailSize)
                    .gesture(offset: $leadingOffset,
                             magnification: $leadingMagnification,
                             canvasSize: proxy.canvasSize)
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .global)
                    } action: { position in
                        wrapper.viewModel.updatePosition(
                            order: .bottom,
                            x: Float(position.origin.x),
                            y: Float(position.origin.y)
                        )
                    }
                
                Spacer()
                
                PHAssetImage(asset: model.trailing, size: thumbnailSize)
                    .gesture(offset: $trailingOffset,
                             magnification: $trailingMagnification,
                             canvasSize: proxy.canvasSize)
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .global)
                    } action: { position in
                        wrapper.viewModel.updatePosition(
                            order: .top,
                            x: Float(position.origin.x),
                            y: Float(position.origin.y)
                        )
                    }
            }
            .frame(maxHeight: .infinity)
            
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
        offset: Binding<CGSize>,
        magnification: Binding<CGFloat>,
        canvasSize: CGSize
    ) -> some View {
        self.modifier(PHAsssetImageGestureModifier(offset: offset, magnification: magnification, canvasSize: canvasSize))
    }
    
    struct PHAsssetImageGestureModifier: ViewModifier {
        
        @Binding private var offset: CGSize
        @Binding private var magnification: CGFloat
        @State private var lastMagnification: CGFloat = 1.0
        
        let canvasSize: CGSize
        
        public init(
            offset: Binding<CGSize>,
            magnification: Binding<CGFloat>,
            canvasSize: CGSize
        ) {
            self._offset = offset
            self._magnification = magnification
            self.canvasSize = canvasSize
        }
        
        func body(content: Content) -> some View {
            content
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.offset = value.translation
                        }.onEnded { _ in
                            withAnimation(.spring()) { self.offset = .zero }
                        }
                        .exclusively(before: MagnifyGesture()
                            .onChanged { value in
                                magnification = lastMagnification * value.magnification
                            }
                            .onEnded { _ in
                                lastMagnification = magnification
                            }
                        )
                )
        }
    }
}
