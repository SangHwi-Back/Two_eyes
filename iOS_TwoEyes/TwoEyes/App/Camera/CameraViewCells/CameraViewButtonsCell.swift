//
//  CameraViewButtonsCell.swift
//  PhotoApp
//
//  Created by SangHwiBack on 3/6/26.
//

import UIKit

class CameraViewButtonsCell: UICollectionViewCell {

    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

extension CameraViewButtonsCell: CameraViewAdaptiveCell {
    func updateTrailCollection(_ traitCollection: UITraitCollection) {
        let isLandscape = traitCollection.verticalSizeClass == .compact
        closeButton.isHidden = isLandscape == false
        buttonStackView.axis = isLandscape ? .vertical : .horizontal
    }
}
