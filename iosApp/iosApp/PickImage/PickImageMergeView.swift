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
    /// 0 = 왼쪽(leading), 1 = 오른쪽(trailing)
    @State private var selectedImageTab = 0

    @EnvironmentObject var navHost: NavigationPathObject<NavHost.Camera>
    @Environment(\.mergeResultDao) var dao
    @Environment(\.appConstant) var constant

    let leadingSource:  PHAsset
    let trailingSource: PHAsset

    init(model: PickImageMergeModel) {
        self._wrapper = State(initialValue: PickImageMergeViewModelWrapper(model: model))
        self.leadingSource  = model.leading
        self.trailingSource = model.trailing
    }

    var body: some View {
        let thumbnailSize: CGSize = CGSize(
            width:  CGFloat(constant.THUMBNAIL_SIZE_WIDTH),
            height: CGFloat(constant.THUMBNAIL_SIZE_HEIGHT)
        )
        let (leadingSize, trailingSize): (CGSize, CGSize) = (
            thumbnailSize * CGFloat(wrapper.leadingState.scale),
            thumbnailSize * CGFloat(wrapper.trailingState.scale)
        )
        let (leadingZIndex, trailingZIndex): (Double, Double) = (
            wrapper.zOrder.first == .top ? 999 : 1000,
            wrapper.zOrder.last  == .top ? 999 : 1000
        )
        let cornerRadius = CGFloat(constant.CARD_CORNER_RADIUS)

        GeometryReader { proxy in
            VStack(spacing: 0) {

                // ── 제스처 캔버스 ────────────────────────────────────────────
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
                        x: (proxy.canvasSize.width  / 2) - 20 - 10,
                        y: (proxy.canvasSize.height / -2) - 20 - 10
                    )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .onAppear {
                    let centerOffsetXDetached = Float(proxy.size.width) / 4
                    wrapper.setCanvasSize(proxy.canvasSize)

                    wrapper.leadingState  = .init(offsetX: -centerOffsetXDetached, offsetY: 0, scale: 1, filter: nil)
                    wrapper.trailingState = .init(offsetX:  centerOffsetXDetached, offsetY: 0, scale: 1, filter: nil)
                }

                Divider().padding(.vertical, 8)

                // ── 필터 선택 ────────────────────────────────────────────────
                FilterSelectorView(
                    selectedTab:    $selectedImageTab,
                    leadingFilter:  wrapper.leadingState.filter,
                    trailingFilter: wrapper.trailingState.filter,
                    onFilterChange: { filter in
                        if selectedImageTab == 0 {
                            wrapper.leadingState = .init(
                                offsetX: wrapper.leadingState.offsetX,
                                offsetY: wrapper.leadingState.offsetY,
                                scale:   wrapper.leadingState.scale,
                                filter:  filter
                            )
                        } else {
                            wrapper.trailingState = .init(
                                offsetX: wrapper.trailingState.offsetX,
                                offsetY: wrapper.trailingState.offsetY,
                                scale:   wrapper.trailingState.scale,
                                filter:  filter
                            )
                        }
                    }
                )

                Divider().padding(.vertical, 8)

                // ── 합성 미리보기 ─────────────────────────────────────────────
                ZStack(alignment: .center) {
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
                            width:  CGFloat(AppConstants.shared.ICON_SIZE_WIDTH),
                            height: CGFloat(AppConstants.shared.ICON_SIZE_HEIGHT)
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: proxy.size.width * 0.65)
                .padding(.horizontal)

                Spacer()

                // ── 확인 버튼 ─────────────────────────────────────────────────
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
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .alert("경고!", isPresented: $mergeDoneAlert) {
            Button("확인", role: .confirm) {}
        } message: {
            Text("이미지 결과에 이상이 발생하였습니다.")
        }
    }
}

// MARK: - Filter Selector View

private struct FilterSelectorView: View {
    @Binding var selectedTab: Int
    let leadingFilter:  PickImageMergeViewModel.ImageState.Filter?
    let trailingFilter: PickImageMergeViewModel.ImageState.Filter?
    let onFilterChange: (PickImageMergeViewModel.ImageState.Filter?) -> Void

    private var currentFilter: PickImageMergeViewModel.ImageState.Filter? {
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
                    ForEach(PickImageMergeViewModel.ImageState.Filter.allFilters, id: \.name) { filter in
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
        }
    }
}

// MARK: - Filter Chip

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

private extension PickImageMergeViewModel.ImageState.Filter {
    /// Swift 에서 Kotlin enum 의 모든 케이스를 열거 (values() 가 Swift 에 직접 노출되지 않으므로 수동 선언)
    static let allFilters: [PickImageMergeViewModel.ImageState.Filter] = [
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
        /// 제스처 시작 시점의 상태를 캡처 — onChanged 마다 base + delta 로 계산
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
                                scale:   base.scale,
                                filter:  base.filter   // filter 보존
                            )
                        }
                        .onEnded { value in
                            guard let base = baseState else { return }
                            imageState = .init(
                                offsetX: base.offsetX + Float(value.translation.width),
                                offsetY: base.offsetY + Float(value.translation.height),
                                scale:   base.scale,
                                filter:  base.filter   // filter 보존
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
                                scale:   base.scale * Float(value.magnification),
                                filter:  base.filter   // filter 보존
                            )
                        }
                        .onEnded { value in
                            guard let base = baseState else { return }
                            imageState = .init(
                                offsetX: base.offsetX,
                                offsetY: base.offsetY,
                                scale:   base.scale * Float(value.magnification),
                                filter:  base.filter   // filter 보존
                            )
                            baseState = nil
                        }
                )
        }
    }
}
