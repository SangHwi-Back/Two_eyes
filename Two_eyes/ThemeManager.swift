//
//  ThemeManager.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/08/19.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
// https://medium.com/@abhimuralidharan/maintaining-a-colour-theme-manager-on-ios-swift-178b8a6a92
//

import UIKit
import Foundation

extension UIColor {
    func colorFromHexString(_ hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return UIColor.red
        }
        
//        var rgbValue: UInt64 = 0
//        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(hexString: cString) ?? UIColor.black
    }
}

class ThemeManager {
    
    let selectedThemeKey = UserDefaults.standard.value(forKey: "MainTheme") as? String ?? Constants.applicationThemeNames[0]
    
    
}
