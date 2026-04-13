//
// Created by SangHwiBack on 2026. 4. 10..
//

import Observation
import UIKit
import Shared

@Observable
final class PickImageViewModelWrapper {
    let viewModel = PickImageViewModel()
    let cameraLauncher: PlatformCameraLauncher
    let photoPickerLauncher: PlatformPhotoPickerLauncher

    private(set) var images = [UIImage]()
    private(set) var capturedImage: UIImage?

    init() {
        cameraLauncher = PlatformCameraLauncher(viewModel: viewModel)
        photoPickerLauncher = PlatformPhotoPickerLauncher(viewModel: viewModel)

        viewModel.onImagesUpdated = { [weak self] images in
            self?.images = images
        }
        viewModel.onImageCaptured = { [weak self] capturedImage in
            self?.capturedImage = capturedImage.image
        }
    }
}
