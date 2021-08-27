//
//  FilterMainHeaderCollectionViewCell.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/08/18.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit
import Photos

class FilterMainHeaderCollectionViewCell: UICollectionViewCell, FilterViewCell {
    
    static var reuseIdentifier: String = "FilterMainHeaderCollectionViewCell"
    var delegate: FilterMainViewTransitionDelegate?
    var asset: PHAsset?
    var filterName: String?
    
    @IBOutlet weak var filteredImageView: FilterImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = FilterTapGesutre(target: self, action: #selector(moveToModalViewSelector(_:)), tapRequired: 2)
        
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func moveToModalViewSelector(_ sender: UITapGestureRecognizer?) {
        delegate?.performFilterSegue(identifier: "FilterAdjustViewController", sender: self)
    }
}
