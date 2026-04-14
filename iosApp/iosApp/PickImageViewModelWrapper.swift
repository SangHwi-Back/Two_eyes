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

//    private(set) var images = [UIImage]()
    private(set) var imageSources = [PHAsset]()
    private(set) var capturedImage: UIImage?

    init() {
        cameraLauncher = PlatformCameraLauncher(viewModel: viewModel)
        photoPickerLauncher = PlatformPhotoPickerLauncher(viewModel: viewModel)

//        viewModel.onImagesUpdated = { [weak self] images in
//            self?.images = images
//        }
        viewModel.onImageSourcesUpdated = { [weak self] sources in
            self?.imageSources = sources
        }
        viewModel.onImageCaptured = { [weak self] capturedImage in
            self?.capturedImage = capturedImage.image
        }
    }
}
