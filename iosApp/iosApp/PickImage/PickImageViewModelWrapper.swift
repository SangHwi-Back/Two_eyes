//
// Created by SangHwiBack on 2026. 4. 10..
//

import Observation
import SwiftUI
import shared
import Photos

@Observable
final class PickImageViewModelWrapper {
    let viewModel = PickImageViewModel()
    let cameraLauncher: PlatformCameraLauncher
    let photoPickerLauncher: PlatformPhotoPickerLauncher!

    private(set) var imageSources = [PHAsset]()
    private(set) var target: PickImageViewModel.TargetModel
    
    var leading: PickImageViewModel.ImageViewModel {
        target.leading
    }
    var trailing: PickImageViewModel.ImageViewModel {
        target.trailing
    }
    var goNextEnabled: Bool {
        target.goNextEnabled
    }
    
    typealias ImageSourcesCollector = MergeCollector<[PHAsset]>
    typealias TargetCollector = MergeCollector<PickImageViewModel.TargetModel>
    typealias CapturedImageCollector = MergeCollector<PHAsset?>

    init() {
        self.cameraLauncher = PlatformCameraLauncher(viewModel: viewModel)
        self.photoPickerLauncher = PlatformPhotoPickerLauncher(imageSourceDelegate: viewModel)
        
        self.target = viewModel.target.value as! PickImageViewModel.TargetModel
        
        viewModel.imageSources
            .collect(collector: ImageSourcesCollector(callback: { [weak self] assets in
                self?.imageSources = assets
            })) { _ in }
        
        viewModel.target
            .collect(collector: TargetCollector(callback: { [weak self] model in
                withAnimation {
                    self?.target = model
                }
            })) { _ in }
    }
}

extension PickImageViewModel.TargetModel {
    var goNextEnabled: Bool {
        leading.imageSource != nil && trailing.imageSource != nil
    }
}
