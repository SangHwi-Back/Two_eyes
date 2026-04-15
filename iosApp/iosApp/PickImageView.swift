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
    
    @State private var wrapper = PickImageViewModelWrapper()
    
    private var viewModel: PickImageViewModel { wrapper.viewModel }
    private var cameraLauncher: PlatformCameraLauncher { wrapper.cameraLauncher }
    private var photoPickerLauncher: PlatformPhotoPickerLauncher { wrapper.photoPickerLauncher }
    
    var goNextEnabled: Bool {
        wrapper.leading.image != nil
        && wrapper.trailing.image != nil
    }
    
    private let thumbnailSize: CGSize = CGSize(width: 120, height: 190)
    
    var body: some View {
        ScrollView { VStack {
            HStack {
                wrapper.leading.getImageView {
                    highLightImageView(isLeft: true)
                }
                Image(systemName: "plus")
                wrapper.trailing.getImageView {
                    highLightImageView(isLeft: false)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .aspectRatio(0.9, contentMode: .fill)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(wrapper.imageSources, id: \.self) { asset in
                        PHAssetImage(asset: asset, size: thumbnailSize)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.trailing)
                            .onTapGesture {
                                Task {
                                    try? await viewModel.setImageFromSource(imageSource: asset)
                                }
                            }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, wrapper.imageSources.isEmpty ? 8 : 12)
            .frame(height: wrapper.imageSources.isEmpty ? 0 : thumbnailSize.height)
            
            HStack {
                Button { cameraLauncher.launch() } label: {
                    BottomButtonImage(systemName: "camera")
                }
                
                Spacer()
                
                BottomButtonImage(systemName: "appwindow.swipe.rectangle")
                    .contextMenu {
                        Button { photoPickerLauncher.launch() } label: {
                            Label("앨범에서 선택", systemImage: "hand.rays")
                        }
                        
                        Button { requestAlbumAccess() } label: {
                            Label("전체 불러오기", systemImage: "photo.on.rectangle.angled")
                        }
                    }
                
                Spacer()
                
                Button { goNext() } label: {
                    BottomButtonImage(
                        systemName: "arrowshape.forward",
                        color: goNextEnabled ? Color.black : Color.secondary)
                }
                .disabled(!goNextEnabled)
            }
            .frame(height: 48)
            .padding(.horizontal)
        }}
    }
    
    private func requestAlbumAccess() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized:
            viewModel.loadAllImages()
        case .limited:
            photoPickerLauncher.launch()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        viewModel.loadAllImages()
                    } else {
                        photoPickerLauncher.launch()
                    }
                }
            }
        default:
            // denied / restricted: PHPicker는 권한 없이도 사용 가능
            photoPickerLauncher.launch()
        }
    }
    
    private func highLightImageView(isLeft: Bool) {
        viewModel.highlightImageView(
            model: isLeft ? wrapper.leading : wrapper.trailing)
    }
    
    private func goNext() {
        if wrapper.imageSources.count >= 2 {
            navHost.push(to: .merge(wrapper.imageSources[0], wrapper.imageSources[1]))
        }
    }
    
    private func BottomButtonImage(
        systemName: String,
        color: Color = Color.primary
    ) -> some View {
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .foregroundStyle(color)
    }
}

extension PickImageViewModel.ImageViewModel {
    @ViewBuilder
    func getImageView(onTapGesture: @escaping () -> Void) -> some View {
        let strokeColor = isHighlighted ? Color.red : Color.gray
        let strokeStyle = StrokeStyle(lineWidth: 1, dash: [6, 10])
        let rectangle = RoundedRectangle(cornerRadius: 8)
            .stroke(strokeColor, style: strokeStyle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        if let image {
            rectangle.overlay {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture { onTapGesture() }
            }
        } else {
            rectangle
                .contentShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture { onTapGesture() }
        }
    }
}

#Preview {
    PickImageView()
}
