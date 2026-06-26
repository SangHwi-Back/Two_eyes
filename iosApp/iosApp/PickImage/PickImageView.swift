//
//  PickImageView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/9/26.
//

import SwiftUI
import Shared
import Photos

struct PickImageView: View {
    @EnvironmentObject var navHost: NavigationPathObject<NavHost.Camera>
    @Environment(\.appConstant) var constant
    
    @State private var wrapper = PickImageViewModelWrapper()
    @State private var showHighlightAlert = false
    @State private var showSettingsAlert = false
    
    @Namespace private var namespace

    private var viewModel: PickImageViewModel { wrapper.viewModel }
    
    var body: some View {
        let thumbnailSize: CGSize = CGSize(
            width: CGFloat(constant.THUMBNAIL_SIZE_WIDTH),
            height: CGFloat(constant.THUMBNAIL_SIZE_HEIGHT)
        )
        ScrollView { VStack {
            HStack {
                wrapper.leading.getImageView {
                    handleImageViewTap($0, isLeading: true)
                }
                Image(systemName: "plus")
                    .foregroundStyle(AppColors.shared.Divider.color)
                wrapper.trailing.getImageView {
                    handleImageViewTap($0, isLeading: false)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .aspectRatio(1.05, contentMode: .fill)
            
            if wrapper.imageSources.isEmpty {
                VStack {
                    Image(systemName: "ellipsis.bubble")
                        .resizable()
                        .foregroundStyle(AppColors.shared.Accent.color)
                        .aspectRatio(contentMode: .fit)
                        .padding(.vertical)
                    Text("Get photos! Using buttons!")
                        .foregroundStyle(AppColors.shared.TextSecondary.color)
                }
                .frame(height: thumbnailSize.height)
            }
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(wrapper.imageSources, id: \.self) { asset in
                        PHAssetImage(asset: asset)
                            .clipShape(RoundedRectangle(cornerRadius: CGFloat(constant.CARD_CORNER_RADIUS)))
                            .padding(.trailing)
                            .onTapGesture { viewModel.setImageFromSource(imageSource: asset) }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, wrapper.imageSources.isEmpty ? 8 : 12)
            .frame(height: wrapper.imageSources.isEmpty ? 0 : thumbnailSize.height)
            
            HStack {
                Spacer()
                
                VStack {
                    HStack(spacing: 8) {
                        GlassIconButton(systemName: "camera") {
                            launchCameraIfHighlighted()
                        }
                        
                        GlassIconButton(systemName: "hand.rays") {
                            wrapper.photoPickerLauncher.launch()
                        }
                    }
                    GlassEffectContainer(spacing: 8) {
                        HStack(spacing: 8) {
                            GlassIconButton(systemName: "photo.on.rectangle.angled") {
                                requestAlbumAccess()
                            }
                            .glassEffectID("photo", in: namespace)
                            
                            if wrapper.target.goNextEnabled {
                                GlassIconButton(systemName: "arrowshape.forward") {
                                    goNext()
                                }
                                .glassEffectID("arrowshape", in: namespace)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }}
        .background(AppColors.shared.Background.color)
        .onAppear {
            // 루트 뷰는 popToRoot() 후에도 파괴되지 않으므로
            // NavigationPathObject 에 콜백을 등록해 상태를 초기화합니다.
            navHost.onPopToRoot = {
                wrapper = PickImageViewModelWrapper()
            }
        }
        .alert("슬롯을 먼저 선택하세요", isPresented: $showHighlightAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("카메라를 열기 전에 이미지를 배치할 슬롯을 먼저 탭해주세요.")
        }
        .alert("사진 전체 접근 권한 필요", isPresented: $showSettingsAlert) {
            Button("설정 열기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("앨범의 모든 사진을 불러오려면 설정에서 사진 접근을 '모든 사진'으로 변경해주세요.")
        }
    }
    
    private func launchCameraIfHighlighted() {
        let isAnyHighlighted = wrapper.leading.isHighlighted || wrapper.trailing.isHighlighted
        if isAnyHighlighted {
            wrapper.cameraLauncher.launch()
        } else {
            showHighlightAlert = true
        }
    }

    private func requestAlbumAccess() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized:
            viewModel.loadAllImages()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        viewModel.loadAllImages()
                    } else {
                        // 전체 권한 미부여 → 설정 안내 알럿
                        showSettingsAlert = true
                    }
                }
            }
        default:
            // limited / denied / restricted: 전체 접근 권한으로 전환 유도
            showSettingsAlert = true
        }
    }
    
    private func handleImageViewTap(_ tap: TapType, isLeading: Bool) {
        let model = isLeading ? wrapper.leading : wrapper.trailing
        switch tap {
        case .highlihgt:
            viewModel.highlightImageView(model: model)
        case .delete:
            viewModel.deleteImage(model: model)
        }
    }
    
    private func goNext() {
        if let left = wrapper.target.leading.imageSource,
           let right = wrapper.target.trailing.imageSource
        {
            navHost.push(to: .merge(left, right))
        }
    }
    
    enum TapType {
        case highlihgt, delete
    }
}

extension PickImageViewModel.ImageViewModel {
    @ViewBuilder
    func getImageView(onTapGesture: @escaping (PickImageView.TapType) -> Void) -> some View {
        
        let strokeColor = isHighlighted
        ? AppColors.shared.Accent.color
        : AppColors.shared.Secondary.color
        let strokeStyle = StrokeStyle(lineWidth: 1, dash: [6, 10])
        let rectangle = RoundedRectangle(cornerRadius: 8)
            .stroke(strokeColor, style: strokeStyle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        if let imageSource {
            rectangle.overlay {
                ZStack(alignment: Alignment.topTrailing) {
                    PHAssetImage(asset: imageSource, size: CGSize(width: 120, height: 190))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture { onTapGesture(.highlihgt) }
                    Image(systemName: "trash")
                        .frame(width: 42, height: 42)
                        .glassEffect(in: .rect(cornerRadius: 21))
                        .offset(.zero)
                        .onTapGesture { onTapGesture(.delete) }
                }
            }
        } else {
            rectangle
                .contentShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture { onTapGesture(.highlihgt) }
        }
    }
}

#Preview {
    PickImageView()
}
