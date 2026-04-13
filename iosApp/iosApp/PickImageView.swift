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

    var target: PickImageViewModel.TargetModel? {
        viewModel.target.value as? PickImageViewModel.TargetModel
    }
    var goNextEnabled: Bool {
        target?.leading.image != nil && target?.trailing.image != nil
    }
    
    var body: some View {
        ScrollView { VStack {
            HStack {
                target
                    .getImageView(isLeading: true)
                    .onTapGesture { highLightImageView(isLeft: true) }
                Image(systemName: "plus")
                target
                    .getImageView(isLeading: false)
                    .onTapGesture { highLightImageView(isLeft: false) }
            }
            .padding(.horizontal)
            .aspectRatio(0.75, contentMode: .fill)
            
            LazyHStack(spacing: 8) {
                ForEach(wrapper.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(width: 120, height: 200)
                        .onTapGesture { viewModel.setImage(image: image) }
                }
            }
            .padding(.horizontal)
            
            HStack {
                Button { cameraLauncher.launch() } label: {
                    BottomButtonImage(systemName: "camera")
                }
                .glassEffect(.regular)
                
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
                .glassEffect(.regular)
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
        guard let model = isLeft ? target?.leading : target?.trailing else {
            return
        }
        
        viewModel.highlightImageView(model: model)
    }
    
    private func goNext() {
        if let leadingImage = target?.leading.image,
           let trailingImage = target?.trailing.image
        {
            navHost.push(to: .merge(leadingImage, trailingImage))
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

extension Optional where Wrapped == PickImageViewModel.TargetModel {
    func getImageView(isLeading: Bool) -> some View {
        let image = isLeading ? self?.leading.image : self?.trailing.image
        let isHighlighted = (isLeading ? self?.leading.isHighlighted : self?.trailing.isHighlighted) ?? false

        return RoundedRectangle(cornerRadius: 8)
            .stroke(isHighlighted ? Color.red : Color.gray, style: StrokeStyle(lineWidth: 1, dash: [6, 10]))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
    }
}

#Preview {
    PickImageView()
}
