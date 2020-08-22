//
//  TowEyesFileManager.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/07/29.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import Foundation

class TwoEyesFileManager {
    static let defaults = UserDefaults.standard
    static let keyForDefault = ""
    
    static func onSwitchClicked(_ label: String?, _ isOn: Bool, _ category: String) {
        if let label = label {
            defaults.set(isOn, forKey: keyForDefault+"."+category+"."+label)
        }
    }
}
