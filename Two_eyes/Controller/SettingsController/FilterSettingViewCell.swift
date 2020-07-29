//
//  FilterSettingViewCell.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/07/29.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit

class FilterSettingViewCell: UITableViewCell {
    
    @IBOutlet weak var filterSettingLabel: UILabel!
    @IBOutlet weak var filterSettingSlider: UISlider!
    @IBOutlet weak var filterSettingSwitch: UISwitch!
    
    @IBAction func onSliderChanged(_ sender: UISlider) {
        
    }
    
    @IBAction func onSwitchClicked(_ sender: UISwitch) {
        TwoEyesFileManager.onSwitchClicked(filterSettingLabel.text, sender.isOn, "filterSetting")
    }
    
}
