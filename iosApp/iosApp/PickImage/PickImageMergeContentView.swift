//
//  PickImageMergeContentView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/13/26.
//

import SwiftUI
import Photos
import Shared

struct PickImageMergeContentView: View {
    let component: MergeImageViewComponent
    // @Observable 클래스는 @State 로 관리해야 부모 뷰 재생성 시 재초기화되지 않음
    @State private var wrapper: PickImageMergeViewModelWrapper
    
    @State private var mergeDoneAlert = false
    /// 0 = 왼쪽(leading), 1 = 오른쪽(trailing)
    @State private var selectedImageTab = 0
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.mergeResultDao) var dao
    @Environment(\.appConstant) var constant
    
    @State var isProxyInitialized = false
    
    let leadingSource:  PHAsset
    let trailingSource: PHAsset
    let horizontalPadding: CGFloat = 16
    
    init(component: MergeImageViewComponent) {
        self.component = component
        let leading = PHAsset.fetchAssets(withLocalIdentifiers: [component.encoded1], options: nil).firstObject!
        let trailing = PHAsset.fetchAssets(withLocalIdentifiers: [component.encoded2], options: nil).firstObject!
        let model = PickImageMergeModel.init(leading: leading, trailing: trailing)
        let wrapper = PickImageMergeViewModelWrapper(model: model)
        self._wrapper = State(initialValue: wrapper)
        self.leadingSource  = model.leading
        self.trailingSource = model.trailing
    }
    
    var body: some View {
        let (leadingZIndex, trailingZIndex): (Double, Double) = (
            wrapper.zOrder.first == .top ? 1000 : 999,
            wrapper.zOrder.last  == .top ? 1000 : 999
        )
        
        let cornerRadius = CGFloat(constant.CARD_CORNER_RADIUS)
        
        let bindLeadingOffset = Binding<PickImageMergeViewModel.ImageState>(
            get: {
                wrapper.leadingState
            }, set: { value, _ in
                wrapper.setLeadingStateValue(.offset(value.offset))
                wrapper.setLeadingStateValue(.scale(value.scale))
            })
        
        let bindTrailingOffset = Binding<PickImageMergeViewModel.ImageState>(
            get: {
                wrapper.trailingState
            }, set: { value, _ in
                wrapper.setTrailingStateValue(.offset(value.offset))
                wrapper.setTrailingStateValue(.scale(value.scale))
            })
        // MARK: 제스처 캔버스
        GeometryReader { proxy in
            VStack(spacing: 0) {
                // MARK: 커스텀 네비게이션 바
                HStack(alignment: .center) {
                    GlassIconButton(systemName: "chevron.left") {
                        dismiss()
                    }
                    Spacer()
                    GlassIconButton(systemName: "arrow.left.arrow.right") {
                        wrapper.viewModel.swapOrder()
                    }
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, horizontalPadding)
                ScrollView(.vertical) {
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(AppColors.shared.Surface.color)
                            .stroke(AppColors.shared.Surface2.color, lineWidth: 1)
                        
                        PHAssetImage(asset: leadingSource, size: wrapper.leadingSize)
                            .draggableAndScalable(bindLeadingOffset)
                            .offset(wrapper.leadingState.offset)
                            .zIndex(leadingZIndex)
                        
                        PHAssetImage(asset: trailingSource, size: wrapper.trailingSize)
                            .draggableAndScalable(bindTrailingOffset)
                            .offset(wrapper.trailingState.offset)
                            .zIndex(trailingZIndex)
                    }
                    .frame(height: CGFloat(constant.THUMBNAIL_SIZE_HEIGHT) * 1.5)
                    .padding(.top)
                    .padding(.horizontal, horizontalPadding)
                    
                    Divider().padding(.vertical, 8)
                    
                    // MARK: 필터 선택
                    FilterSelectorView(
                        selectedTab:    $selectedImageTab,
                        leadingFilter:  wrapper.leadingState.filter,
                        trailingFilter: wrapper.trailingState.filter,
                        onFilterChange: {
                            wrapper.setLeadingStateValue(.filter($0))
                        }
                    )
                    
                    Divider().padding(.vertical, 8)
                    
                    // MARK: 합성 미리보기
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(AppColors.shared.Surface.color)
                            .stroke(AppColors.shared.Surface2.color, lineWidth: 1)
                        
                        if let image = $wrapper.mergedImage.wrappedValue {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(height: CGFloat(constant.THUMBNAIL_SIZE_HEIGHT) * 1.5)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom)
                }
                
                HStack(alignment: .bottom) {
                    Spacer()
                    
                    Text("Upload")
                        .font(.footnote)
                        .foregroundStyle(AppColors.shared.TextPrimary.color)
                    
                    GlassIconButton(systemName: "checkmark.circle") {
                        let isSuccess = wrapper.mergeDone(dao: dao)
                        if isSuccess {
                            component.onConfirmClicked()
                        } else {
                            mergeDoneAlert = true
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)
            }
            .frame(width: proxy.size.width)
            // overlay 로 배치: .offset() 으로 ZStack 프레임 밖에 놓으면 히트 테스트가
            // 프레임 바깥 터치를 처리하지 않아 버튼이 반응하지 않는 문제를 방지.
            .onAppear {
                guard isProxyInitialized == false else {
                    return
                }
                
                let canvasWidth = proxy.size.width - Double(horizontalPadding * 2)
                let centerOffsetXDetached = canvasWidth / 8
                wrapper.setCanvasSize(CGSize(
                    width: canvasWidth,
                    height: CGFloat(constant.THUMBNAIL_SIZE_HEIGHT) * 1.5))
                
                let leadingOffset = CGSize(width: Int(centerOffsetXDetached), height: 0)
                wrapper.setLeadingStateValue(.offset(leadingOffset))
                
                let trailingOffset = CGSize(width: Int(centerOffsetXDetached * 3), height: 0)
                wrapper.setTrailingStateValue(.offset(trailingOffset))
                
                isProxyInitialized = true
            }
            
        }
        .frame(maxWidth: .infinity)
        .toolbar(.hidden, for: .navigationBar, .tabBar)
        .background(AppColors.shared.Background.color.ignoresSafeArea())
        .alert("경고!", isPresented: $mergeDoneAlert) {
            Button("확인", role: .confirm) {}
        } message: {
            Text("이미지 결과에 이상이 발생하였습니다.")
        }
    }
}

private struct FilterSelectorView: View {
    @Binding var selectedTab: Int
    let leadingFilter:  PickImageMergeViewModel.ImageStateFilter?
    let trailingFilter: PickImageMergeViewModel.ImageStateFilter?
    let onFilterChange: (PickImageMergeViewModel.ImageStateFilter?) -> Void
    
    private var currentFilter: PickImageMergeViewModel.ImageStateFilter? {
        selectedTab == 0 ? leadingFilter : trailingFilter
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 이미지 선택 탭
            Picker("이미지", selection: $selectedTab) {
                Text("왼쪽").tag(0)
                Text("오른쪽").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top)
            
            // 필터 칩 목록
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // "없음" 칩
                    FilterChipView(
                        label:      "없음",
                        isSelected: currentFilter == nil
                    ) {
                        onFilterChange(nil)
                    }
                    // 각 필터 칩
                    ForEach(PickImageMergeViewModel.ImageStateFilter.allFilters, id: \.name) { filter in
                        FilterChipView(
                            label:      filter.filterLabel,
                            isSelected: currentFilter?.isEqual(filter) == true
                        ) {
                            onFilterChange(filter)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .background(AppColors.shared.Surface2.color)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(AppConstants.shared.CARD_CORNER_RADIUS)))
        .padding(.horizontal)
    }
}

private struct FilterChipView: View {
    let label:      String
    let isSelected: Bool
    let action:     () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Filter Extensions

private extension PickImageMergeViewModel.ImageStateFilter {
    /// Swift 에서 Kotlin enum 의 모든 케이스를 열거 (values() 가 Swift 에 직접 노출되지 않으므로 수동 선언)
    static let allFilters: [PickImageMergeViewModel.ImageStateFilter] = [
        .inverted, .monochrome, .contrast, .saturation, .vignette
    ]
    
    var filterLabel: String {
        switch self {
        case .inverted:   return "반전"
        case .monochrome: return "흑백"
        case .contrast:   return "대비"
        case .saturation: return "채도"
        case .vignette:   return "비네트"
        default:          return name
        }
    }
}

// MARK: - ImageState Extensions

private extension PickImageMergeViewModel.ImageState {
    var offset: CGSize {
        CGSize(width: CGFloat(offsetX), height: CGFloat(offsetY))
    }
}

// MARK: - GeometryProxy Extension

private extension GeometryProxy {
    var canvasSize: CGSize {
        CGSize(width: size.width, height: 300)
    }
}

// MARK: - Gesture Modifier

private extension PHAssetImage {
    /// 드래그(위치 누적) + 핀치 줌을 동시에 지원하는 modifier.
    /// 제스처 중에도 filter 상태를 보존한다.
    func draggableAndScalable(_ state: Binding<PickImageMergeViewModel.ImageState>) -> some View {
        self.modifier(DraggableScalableModifier(imageState: state))
    }
    
    struct DraggableScalableModifier: ViewModifier {
        @Binding var imageState: PickImageMergeViewModel.ImageState
        
        /// 제스처 시작 시점의 값 — translation / magnification 은 시작점 기준 누적값이므로
        /// 매 이벤트마다 "시작값 + 변화량" 으로 계산해야 중복 누적되지 않는다.
        @State private var dragBase: CGSize?
        @State private var magnifyBase: Float?
        
        func body(content: Content) -> some View {
            content
                .simultaneousGesture(
                    // 뷰 자체가 .offset 으로 움직이므로 local 좌표를 쓰면 translation 이 흔들린다.
                    DragGesture(coordinateSpace: .global)
                        .onChanged { value in
                            let base = dragBase ?? CGSize(
                                width: CGFloat(imageState.offsetX),
                                height: CGFloat(imageState.offsetY))
                            dragBase = base
                            update(offsetX: base.width + value.translation.width,
                                   offsetY: base.height + value.translation.height)
                        }
                        .onEnded { _ in dragBase = nil }
                )
                .simultaneousGesture(
                    MagnifyGesture()
                        .onChanged { value in
                            let base = magnifyBase ?? imageState.scale
                            magnifyBase = base
                            update(scale: base * Float(value.magnification))
                        }
                        .onEnded { _ in magnifyBase = nil }
                )
        }
        
        /// 변경하지 않는 값(filter 포함)은 현재 상태를 그대로 보존한다.
        private func update(offsetX: CGFloat? = nil, offsetY: CGFloat? = nil, scale: Float? = nil) {
            imageState = .init(
                offsetX: offsetX.map(Float.init) ?? imageState.offsetX,
                offsetY: offsetY.map(Float.init) ?? imageState.offsetY,
                scale:   scale ?? imageState.scale,
                filter:  imageState.filter
            )
        }
    }
}
