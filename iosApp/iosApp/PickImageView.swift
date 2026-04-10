//
//  PickImageView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/9/26.
//

import SwiftUI
import Shared

struct PickImageView: View {
    let viewModelWrapper = PickImageViewModelWrapper()
    var viewModel: PickImageViewModel {
        viewModelWrapper.viewModel
    }
    var target: PickImageViewModel.TargetModel? {
        viewModel.target.value as? PickImageViewModel.TargetModel
    }
    
    var body: some View {
        ScrollView { VStack {
            HStack {
                Image("")
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .border((target?.trailing.isHighlighted ?? false) ? Color.red : Color.gray, width: 1)
                    .onTapGesture {
                        highLightImageView(isLeft: true)
                    }
                Image(systemName: "plus")
                Image("")
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .border((target?.leading.isHighlighted ?? false) ? Color.red : Color.gray, width: 1)
                    .onTapGesture {
                        highLightImageView(isLeft: false)
                    }
            }
            .frame(height: 200)
            
            LazyHStack(spacing: 8) {
                ForEach(viewModelWrapper.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(width: 120, height: 200)
                }
            }
            
            HStack {
                Button("", systemImage: "camera") {}
                Button("", systemImage: "photo.on.rectangle.angled") {
                    viewModel.loadAllImages()
                }
                Button("", systemImage: "arrowshape.forward") {}
            }
            .frame(height: 56)
        }}
    }
    
    func highLightImageView(isLeft: Bool) {
        guard let model = isLeft ? target?.leading : target?.trailing else {
            return
        }
        
        viewModel.highlightImageView(model: model)
    }
}

#Preview {
    PickImageView()
}
