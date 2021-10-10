//
//  UIColor+Extension.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/09/01.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init?(hex: String?) {
        
        guard hex != nil && hex?.replacingOccurrences(of: " ", with: "") != "" else {
            self.init(white: 0.0, alpha: 0.0) // clear color.
            return nil
        }
        
        let r, g, b, a: CGFloat
        let hexString = hex!

        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
    
    func toRGBString() -> String {
        let ciColor = CIColor(color: self)
        return "\(ciColor.red).\(ciColor.blue).\(ciColor.green)"
    }
}

extension Optional where Wrapped == UIColor {
    
    func toRGBString() -> String {
        
        guard self != nil else {
            return ""
        }
        
        let ciColor = CIColor(color: self!)
        return "\(ciColor.red).\(ciColor.blue).\(ciColor.green)"
    }
}
