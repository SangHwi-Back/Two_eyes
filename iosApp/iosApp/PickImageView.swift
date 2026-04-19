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
    
    var goNextEnabled: Bool {
        wrapper.leading.imageSource != nil
        && wrapper.trailing.imageSource != nil
    }
    
    private let thumbnailSize: CGSize = CGSize(width: 120, height: 190)
    
    var body: some View {
        ScrollView { VStack {
            HStack {
                wrapper.leading.getImageView {
                    handleImageViewTap($0, isLeading: true)
                }
                Image(systemName: "plus")
                wrapper.trailing.getImageView {
                    handleImageViewTap($0, isLeading: false)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .aspectRatio(0.9, contentMode: .fill)
            
            if wrapper.imageSources.isEmpty {
                VStack {
                    Image(systemName: "ellipsis.bubble")
                        .resizable()
                        .foregroundStyle(Color.black)
                        .aspectRatio(contentMode: .fit)
                        .padding(.vertical)
                    Text("Get photos! Using buttons!")
                }
                .frame(height: thumbnailSize.height)
            }
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(wrapper.imageSources, id: \.self) { asset in
                        PHAssetImage(asset: asset, size: thumbnailSize)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.trailing)
                            .onTapGesture { viewModel.setImageFromSource(imageSource: asset) }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, wrapper.imageSources.isEmpty ? 8 : 12)
            .frame(height: wrapper.imageSources.isEmpty ? 0 : thumbnailSize.height)
            
            HStack {
                Button { wrapper.cameraLauncher.launch() } label: {
                    BottomButtonImage(image: Image(systemName: "camera"), title: "Camera")
                }
                
                Spacer()
                
                Button { wrapper.photoPickerLauncher.launch() } label: {
                    BottomButtonImage(image: Image(systemName: "hand.rays"), title: "Pick")
                }
                
                Spacer()
                
                Button { requestAlbumAccess() } label: {
                    BottomButtonImage(image: Image(systemName: "photo.on.rectangle.angled"), title: "GetAll")
                }
                Spacer()
                
                Button { goNext() } label: {
                    let color = goNextEnabled ? Color.black : Color.secondary
                    BottomButtonImage(
                        image: Image(systemName: "arrowshape.forward"),
                        title: "Next",
                        foregroundColor: color)
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
            wrapper.photoPickerLauncher.launch()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        viewModel.loadAllImages()
                    } else {
                        wrapper.photoPickerLauncher.launch()
                    }
                }
            }
        default:
            // denied / restricted: PHPicker는 권한 없이도 사용 가능
            wrapper.photoPickerLauncher.launch()
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
    
    private func BottomButtonImage(
        image: Image,
        title: String,
        foregroundColor: Color = Color.primary
    ) -> some View {
        VStack {
            image
            Text(title)
        }
        .frame(idealWidth: 50, maxWidth: 100, idealHeight: 80, maxHeight: 80, alignment: .center)
        .foregroundStyle(foregroundColor)
        .glassEffect(in: .rect(cornerRadius: 8))
    }
    
    enum TapType {
        case highlihgt, delete
    }
}

extension PickImageViewModel.ImageViewModel {
    @ViewBuilder
    func getImageView(onTapGesture: @escaping (PickImageView.TapType) -> Void) -> some View {
        let strokeColor = isHighlighted ? Color.red : Color.gray
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
