//
//  BroadCastingTabBarController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/11.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit

protocol BroadCastingTabBarControllerDelegate: class {
    func addInitialImage(_ capturedImage: UIImage?)
}

class BroadCastingTabBarController: UITabBarController {
    
    var capturedImage: UIImage?
    weak var broadCastingDelegate: BroadCastingTabBarControllerDelegate?
    private let themeManager = (UIApplication.shared.delegate as! AppDelegate).themeManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        super.delegate = self
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.view.backgroundColor = themeManager.getThemeBackgroundColor()
    }

    @IBAction func cameraBtnTab(_ sender: UIBarButtonItem) {
        self.selectedIndex = 0
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let title = item.title {
            switch title {
            case "Search":
                tabBarController?.selectedIndex = 1
                navigationItem.title = "Search"
            case "Camera&Filter":
                tabBarController?.selectedIndex = 2
                navigationItem.title = "Camera&Filter"
            case "Settings":
                tabBarController?.selectedIndex = 0
                navigationItem.title = "Settings"
            default:
                return
            }
        }
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = themeManager.getNavtabBackgroundColor()
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.backgroundColor = themeManager.getNavtabBackgroundColor()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        viewController.view.backgroundColor = themeManager.getThemeBackgroundColor()
        
        if let vc = viewController as? SearchAndLoadViewController {
            vc.albumCollectionView.backgroundColor = themeManager.getThemeBackgroundColor()
            vc.albumSearchBar.barTintColor = themeManager.getThemeBackgroundColor()
        } else if let vc = viewController as? SettingsTableViewController {
            vc.view.backgroundColor = themeManager.getThemeBackgroundColor()
            vc.tableView.dequeueReusableCell(withIdentifier: "settingRows")?.contentView.backgroundColor = themeManager.getThemeBackgroundColor()
        }
        
//        self.tabBar.isTranslucent = false
//        self.tabBar.backgroundColor = themeManager.getThemeBackgroundColor()
        return true
    }
    
}


extension BroadCastingTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
}
