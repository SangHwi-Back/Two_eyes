//
//  CameraViewImagePreviewCell.swift
//  TwoEyes
//
//  Created by 백상휘 on 3/13/26.
//

import UIKit

class CameraViewImagePreviewCell: UICollectionViewCell {

    @IBOutlet weak var leadingImageView: UIImageView!
    @IBOutlet weak var trailingImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateImages(_ images: [UIImage]) {
        leadingImageView.image = images.first
        if images.count > 1 {
            trailingImageView.image = images.last
        } else {
            trailingImageView.image = nil
        }
    }
}

extension CameraViewImagePreviewCell: CameraViewAdaptiveCell {
    func updateTrailCollection(_ traitCollection: UITraitCollection) {
        
    }
}
