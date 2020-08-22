//
//  MainSettingViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/08/21.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import CoreData

class MainSettingViewController: UIViewController {

    @IBOutlet weak var LogoutLabel: UILabel!
    
    @IBOutlet weak var themeChooserCollectionView: UICollectionView!
    
    var cellSize = CGSize()
    var cellLabelSize = CGSize()
    var cellImageViewSize = CGSize()
    
    let choosedTheme = UserDefaults.standard.value(forKey: "MainTheme") ?? "Egg_Tart"
    let container = NSPersistentContainer(name: Constants.themeEntityName)
    
    let themeManager: ThemeManager? = (UIApplication.shared.delegate as? AppDelegate)?.themeManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellSize = CGSize(
            width: view.frame.width / 2.5 - 10,
            height: (view.frame.width / 2.5 - 10) * 1.2
        )
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.minimumLineSpacing = 30
        
        themeChooserCollectionView.delegate = self
        themeChooserCollectionView.dataSource = self
        themeChooserCollectionView.register(UINib(nibName: "MainSettingViewCell", bundle: nil), forCellWithReuseIdentifier: "mainSettingViewCell")
        themeChooserCollectionView.awakeFromNib()
        themeChooserCollectionView.allowsSelection = true
        themeChooserCollectionView.setCollectionViewLayout(layout, animated: true)
        themeChooserCollectionView.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
}

extension MainSettingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Constants.applicationThemeNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainSettingViewCell", for: indexPath) as? MainSettingViewCell,
            let storedThemes = self.themeManager?.storedThemes else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainSettingViewCell", for: indexPath)
            cell.frame = CGRect(x: 0, y: 0, width: 150, height: 180)
            cell.backgroundColor = .black
            return cell
        }
        
        let themeName = Constants.applicationThemeNames[indexPath.row]
        let themeInfo = storedThemes.filter { $0.id == themeName }.first!
        
//        let themeInfo = Constants.applicationDefaultThemes[themeName]!.filter {$0.key != "id"}.mapValues{
//            return themeName == "Default" ? UIColor.white : $0.toUIColor
//        }
        
        cell.label.text = themeName
        cell.themeName = themeName
        
        for (index, imageView) in cell.imageViewStack.subviews.enumerated() where imageView is UIImageView {
            if themeName == "Default" {
                continue
            }
            
            if let colorString = themeInfo.value(forKey: Constants.themeKeys[index]) as? String {
                imageView.backgroundColor = colorString.toUIColor
            }
//            imageView.backgroundColor = (themeInfo.value(forKey: Constants.themeKeys[index]) as! String).toUIColor
            imageView.layer.borderWidth = 0.5
            imageView.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1.0)
        }
        
        return cell
    }
}

extension MainSettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MainSettingViewCell else {
            return
        }
        
        cell.isHighlighted = true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isHighlighted = false
    }
}
