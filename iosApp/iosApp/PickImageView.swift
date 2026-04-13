//
//  PickImageView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/9/26.
//

import SwiftUI
import Shared

struct PickImageView: View {
    @EnvironmentObject var navHost: NavigationPathObject<NavHost.Camera>
    
    var viewModel: PickImageViewModel {
        viewModelWrapper.viewModel
    }
    var target: PickImageViewModel.TargetModel? {
        viewModel.target.value as? PickImageViewModel.TargetModel
    }
    
    let viewModelWrapper: PickImageViewModelWrapper
    let cameraLauncher: PlatformCameraLauncher

    init() {
        let wrapper = PickImageViewModelWrapper()
        self.viewModelWrapper = wrapper
        self.cameraLauncher = .init(viewModel: wrapper.viewModel)
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
            .aspectRatio(1.21, contentMode: .fill)
            
            LazyHStack(spacing: 8) {
                ForEach(viewModelWrapper.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(width: 120, height: 200)
                        .onTapGesture { viewModel.setImage(image: image) }
                }
            }
            .padding(.horizontal)
            
            HStack {
                Button("", systemImage: "camera") {
                    cameraLauncher.launch()
                }
                Spacer()
                Button("", systemImage: "photo.on.rectangle.angled") {
                    viewModel.loadAllImages()
                }
                Spacer()
                Button("", systemImage: "arrowshape.forward") {
                    if let leadingImage = target?.leading.image,
                       let trailingImage = target?.trailing.image
                    {
                        navHost.push(to: .merge(leadingImage, trailingImage))
                    }
                }
                .disabled(
                    target?.leading.image != nil
                    && target?.trailing.image != nil)
            }
            .frame(height: 56)
            .padding(.horizontal)
        }}
    }
    
    func highLightImageView(isLeft: Bool) {
        guard let model = isLeft ? target?.leading : target?.trailing else {
            return
        }
        
        viewModel.highlightImageView(model: model)
    }
}

extension Optional where Wrapped == PickImageViewModel.TargetModel {
    func getImageView(isLeading: Bool) -> some View {
        let image = isLeading ? self?.leading.image : self?.trailing.image
        let isHighlighted = isLeading ? self?.leading.isHighlighted : self?.trailing.isHighlighted
        let borderColor = (isHighlighted ?? false) ? Color.red : Color.gray
        
        let result: Image = {
            if let image {
                return Image(uiImage: image)
            } else {
                return Image(systemName: "rectangle.dashed")
            }
        }()
        
        return result
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .border(borderColor, width: 1)
    }
}

#Preview {
    PickImageView()
}
