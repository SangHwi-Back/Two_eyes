//
// Created by SangHwiBack on 2026. 4. 10..
//

import Observation
import UIKit
import Shared
import Photos

@Observable
final class PickImageViewModelWrapper {
    let viewModel = PickImageViewModel()
    let cameraLauncher: PlatformCameraLauncher
    let photoPickerLauncher: PlatformPhotoPickerLauncher

    private(set) var imageSources = [PHAsset]()
    private(set) var capturedImage: UIImage?
    private(set) var target: PickImageViewModel.TargetModel
    
    var leading: PickImageViewModel.ImageViewModel {
        target.leading
    }
    var trailing: PickImageViewModel.ImageViewModel {
        target.trailing
    }
    
    typealias ImageSourcesCollector = Collector<[PHAsset]>
    typealias TargetCollector = Collector<PickImageViewModel.TargetModel>
    typealias CapturedImageCollector = Collector<CapturedImage?>

    init() {
        self.cameraLauncher = PlatformCameraLauncher(viewModel: viewModel)
        self.photoPickerLauncher = PlatformPhotoPickerLauncher(viewModel: viewModel)
        
        self.target = viewModel.target.value as! PickImageViewModel.TargetModel
        
        viewModel.imageSources
            .collect(collector: ImageSourcesCollector(callback: { [weak self] assets in
                self?.imageSources = assets
            })) { _ in }
        
        viewModel.target
            .collect(collector: TargetCollector(callback: { [weak self] model in
                self?.target = model
            })) { _ in }
        
        viewModel.capturedImage
            .collect(collector: CapturedImageCollector(callback: { [weak self] image in
                self?.capturedImage = image?.image
            })) { _ in }
    }
}
