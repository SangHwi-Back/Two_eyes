//
//  MainSettingViewCell.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/08/21.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit

class MainSettingViewCell: UICollectionViewCell {
    @IBOutlet var imageViewStack: UIStackView!
    
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var imageView2: UIImageView!
    @IBOutlet var imageView3: UIImageView!
    @IBOutlet var imageView4: UIImageView!
    @IBOutlet var imageView5: UIImageView!
    
    @IBOutlet var label: UILabel!
    
    var themeName: String = ""
    var themeInfo: ApplicationTheme?
    
}
