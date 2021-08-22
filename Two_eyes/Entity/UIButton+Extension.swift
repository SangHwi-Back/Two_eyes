//
//  UIButton+Extension.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/03/30.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

public extension UIButton {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    
    
}
