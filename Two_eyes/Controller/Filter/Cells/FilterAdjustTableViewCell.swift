//
//  FilterAdjustTableViewCell.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/08/26.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

class FilterAdjustTableViewCell: UITableViewCell {

    @IBOutlet weak var labelWidth: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
