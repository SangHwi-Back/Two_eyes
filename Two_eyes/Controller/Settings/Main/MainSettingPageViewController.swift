//
//  MainSettingPageViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/09/25.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

class MainSettingPageViewController: UIPageViewController {
    
//    var pageItems: [UIViewController]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers(self.initiateViewController(), direction: .forward, animated: true, completion: nil)
    }
    
    func initiateViewController() -> [UIViewController] {
        var result = [UIViewController]()
        
        for identifier in ["CameraViewController","SearchAndLoadViewController","SettingsTableViewController"] {
            
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: identifier)
            
            if vc.restorationIdentifier == "CameraViewController" {
                (vc as? CameraViewController)?.currentPictureRequested = false
            }
            
            result.append(vc)
        }
        
        return result
    }
}
