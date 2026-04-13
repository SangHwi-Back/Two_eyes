//
// Created by SangHwiBack on 2026. 4. 10..
//

import Observation
import UIKit
import Shared

@Observable
final class PickImageViewModelWrapper {
    let viewModel = PickImageViewModel()

    private(set) var images = [UIImage]()
    private(set) var capturedImage: UIImage?

    init() {
        viewModel.onImagesUpdated = { [weak self] images in
            self?.images = images
        }
        viewModel.onImageCaptured = { [weak self] capturedImage in
            self?.capturedImage = capturedImage.image
        }
    }
}
