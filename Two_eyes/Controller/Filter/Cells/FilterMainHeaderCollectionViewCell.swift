//
//  FilterMainHeaderCollectionViewCell.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/08/18.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

class FilterMainHeaderCollectionViewCell: UICollectionViewCell {
    var delegate: FilterMainViewControllerTransitionDelegate?
    
    @IBOutlet weak var filteredImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = FilterTapGesutre(target: self, action: #selector(moveToModalViewSelector(_:)), tapRequired: 2)
        
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func moveToModalViewSelector(_ sender: UITapGestureRecognizer?) {
        delegate?.performFilterSegue(identifier: "FilterAdjustViewController")
    }
}
