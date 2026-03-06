//
//  MainTabBarController.swift
//  PhotoApp
//
//  Created by SangHwiBack on 2/26/26.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let feedVC: UIViewController = {
        let storyboard = UIStoryboard(name: "FeedScene", bundle: nil)
        return storyboard.instantiateInitialViewController() ?? FeedViewController()
    }()
    
    let uploadVC: UIViewController = {
        let storyboard = UIStoryboard(name: "Upload", bundle: nil)
        return storyboard.instantiateInitialViewController() ?? UploadViewController()
    }()
    
    let cameraVC: UIViewController = {
        let storyboard = UIStoryboard(name: "Camera", bundle: nil)
        return storyboard.instantiateInitialViewController() ?? CameraViewController()
    }()
    
    let settingButton: UIButton = {
        let button = UIButton()
        var conf: UIButton.Configuration = {
            if #available(iOS 26, *) {
                return .clearGlass()
            } else {
                return .plain()
            }
        }()
        
        conf.image = UIImage(systemName: "gear")
        button.configuration = conf
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedVC.tabBarItem = UITabBarItem(
            title: "Feed", image: UIImage(systemName: "menubar.arrow.down.rectangle"), tag: 0)
        cameraVC.tabBarItem = UITabBarItem(
            title: "Camera", image: UIImage(systemName: "camera.aperture"), tag: 1)
        uploadVC.tabBarItem = UITabBarItem(
            title: "Upload", image: UIImage(systemName: "square.and.arrow.up"), tag: 2)
        
        tabBar.itemPositioning = .centered
        tabBar.itemSpacing = 75.0
        
        viewControllers = [feedVC, cameraVC, uploadVC]
        
        view.addSubview(settingButton)
        settingButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            settingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            settingButton.widthAnchor.constraint(equalToConstant: 44),
            settingButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        settingButton.addAction(.init(handler: { _ in
            self.performSegue(withIdentifier: "showSettings", sender: self.settingButton)
        }), for: .touchUpInside)
    }
}
