//
//  String+Extension.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/09/29.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var toUIColor: UIColor {
        let rgb = Array(self.split(separator: ".").map{String($0)})
        return UIColor(displayP3Red: CGFloat(Int(rgb[0])!) / 255, green: CGFloat(Int(rgb[1])!) / 255, blue: CGFloat(Int(rgb[2])!) / 255, alpha: 1)
    }
}
