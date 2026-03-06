//
//  CameraViewSelectedImagesCell.swift
//  PhotoApp
//
//  Created by SangHwiBack on 3/6/26.
//

import UIKit

class CameraViewSelectedImagesCell: UICollectionViewCell {

    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var leadingImageView: UIImageView!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var trailingImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateImages(_ images: [UIImage]) {
        if let image = images.first {
            leadingImageView.image = image
        }
        
        if let image = images.last, images.count > 1 {
            trailingImageView.image = image
        }
    }

}

extension CameraViewSelectedImagesCell: CameraViewAdaptiveCell {
    func updateTrailCollection(_ traitCollection: UITraitCollection) {
        let isLandscape = traitCollection.horizontalSizeClass == .compact
        imageStackView.axis = isLandscape ? .horizontal : .vertical
    }
}
