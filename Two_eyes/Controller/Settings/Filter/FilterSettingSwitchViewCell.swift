//
//  FilterSettingSwitchViewCell.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/09/15.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

class FilterSettingSwitchViewCell: UITableViewCell {

    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    
    static var cellIdentifier = "FilterSettingSwitchViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func settingSwitchValueChanged(_ sender: UISwitch) {
        TwoEyesFileManager.onSwitchClicked(contentsLabel.text, sender.isOn, "filterSetting")
    }
}
