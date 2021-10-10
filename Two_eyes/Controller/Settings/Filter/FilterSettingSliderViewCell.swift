//
//  FilterSettingSliderViewCell.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/09/15.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

class FilterSettingSliderViewCell: UITableViewCell {

    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var settingSlider: UISlider!
    
    static var cellIdentifier = "FilterSettingSliderViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
