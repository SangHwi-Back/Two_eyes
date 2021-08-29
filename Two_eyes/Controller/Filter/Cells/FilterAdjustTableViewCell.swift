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
    
    var adjustKey: FilterAdjustKey? {
        didSet {
            self.nameLabel.text = adjustKey?.rawValue
        }
    }
    var imageViewSize: CGSize = CGSize(width: 0, height: 0)
    
    var delegate: FilterAdjustDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func valueSliderChanged(_ sender: UISlider) {
        guard let key = self.adjustKey else { return }
        sender.value = round(sender.value / 0.1) * 0.1
        delegate?.valueSliderChanged(key: key, value: sender.value)
    }
}
