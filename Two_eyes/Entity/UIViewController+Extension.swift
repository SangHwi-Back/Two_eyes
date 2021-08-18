//
//  UIViewController+Extension.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/03/20.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setTheme() {
        
        let themeManager = (UIApplication.shared.delegate as! AppDelegate).themeManager!
        
        self.navigationController?.navigationBar.isTranslucent = (themeManager.getNavtabBackgroundColor() == UIColor.systemBackground ? true : false)
        self.navigationController?.navigationBar.barTintColor = themeManager.getNavtabBackgroundColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: themeManager.getBodyTextColor()]
        self.tabBarController?.tabBar.barTintColor = themeManager.getNavtabBackgroundColor()
        self.view.backgroundColor = themeManager.getThemeBackgroundColor()
    }
    
}
