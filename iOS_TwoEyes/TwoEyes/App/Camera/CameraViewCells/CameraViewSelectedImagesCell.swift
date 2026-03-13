//
//  CameraViewSelectedImagesCell.swift
//  PhotoApp
//
//  Created by SangHwiBack on 3/6/26.
//

import UIKit

class CameraViewSelectedImagesCell: UICollectionViewCell {

    @IBOutlet weak var parentStackView: UIStackView!
    
    @IBOutlet weak var verticalView: UIStackView!
    
    @IBOutlet weak var landscapeView: UIView!
    
    @IBOutlet weak var leadingImageView: UIImageView!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var trailingImageView: UIImageView!
    
    @IBOutlet weak var leadingLandscapeImageView: UIImageView!
    @IBOutlet weak var centerLandscapeImageView: UIImageView!
    @IBOutlet weak var trailingLandscapeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateImages(_ images: [UIImage]) {
        if let image = images.first {
            leadingImageView.image = image
            leadingLandscapeImageView.image = image
        }
        
        if let image = images.last, images.count > 1 {
            trailingImageView.image = image
            trailingLandscapeImageView.image = image
        }
    }

}

extension CameraViewSelectedImagesCell: CameraViewAdaptiveCell {
    func updateTrailCollection(_ traitCollection: UITraitCollection) {
        let isLandscape = traitCollection.verticalSizeClass == .compact
        verticalView.isHidden = isLandscape
        landscapeView.isHidden = !isLandscape
    }
}
