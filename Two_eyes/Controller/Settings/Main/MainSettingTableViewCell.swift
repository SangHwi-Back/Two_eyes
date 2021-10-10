//
//  MainSettingTableViewCell.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/09/26.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

class MainSettingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var colorStackView: UIStackView!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    var deleagte: MainSettingDelegate?
    var info: ThemeInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func stackColors() {
        
        guard let info = info else {
            return
        }
        
        for hex in [info.navigationBackgroundColor!, info.bodyTextColor!, info.buttonBackgroundColor!, info.buttonTextColor!] {
            
            DispatchQueue.main.async {
                
                let colorView = UIView()
                colorView.backgroundColor = UIColor(hex: hex)
                colorView.frame.size = CGSize(width: self.colorStackView.frame.width, height: self.colorStackView.frame.height/5)
                self.colorStackView.addArrangedSubview(colorView)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func infoButtonTouchUpInside(_ sender: UIButton) {
        deleagte?.delegateShow()
    }
}
