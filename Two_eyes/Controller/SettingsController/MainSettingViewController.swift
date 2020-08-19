//
//  MainSettingViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/07/29.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit

class MainSettingViewController: UIViewController {

    @IBOutlet weak var LogoutLabel: UILabel!
    
    @IBOutlet weak var themeChooserCollectionView: UICollectionView!
    
    var cellSize = CGSize()
    var cellLabelSize = CGSize()
    var cellImageViewSize = CGSize()
    
    let choosedTheme = UserDefaults.standard.value(forKey: "MainTheme") ?? "Egg_Tart"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellSize = CGSize(
            width: view.frame.width / 2.5 - 10,
            height: (view.frame.width / 2.5 - 10) * 1.2
        )
        
        cellLabelSize = CGSize(width: cellSize.width, height: cellSize.width * 0.2)
        cellImageViewSize = CGSize(width: cellSize.width, height: cellSize.width)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        layout.minimumLineSpacing = 30
        
        themeChooserCollectionView.delegate = self
        themeChooserCollectionView.dataSource = self
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "themeSettingCell", for: indexPath)
        
        if let cellLabel = cell.subviews.first?.subviews.filter({ $0 is UILabel }).first as? UILabel {
            cellLabel.bounds.size.height = cellSize.width * 0.2
            cellLabel.bounds.size.width = cellSize.width
            cellLabel.text = Constants.applicationThemeNames[indexPath.row]
        }
        
        if let cellImageView = cell.subviews.first?.subviews.filter({ $0 is UIImageView }).first as? UIImageView {
            let cellColorsLayer = CAGradientLayer()
            cellColorsLayer.frame = cell.bounds
            cellColorsLayer.colors = [
                UIColor.red.cgColor,
                UIColor.blue.cgColor,
                UIColor.gray.cgColor,
                UIColor.purple.cgColor,
                UIColor.white.cgColor,
                UIColor.brown.cgColor
            ]
            cellColorsLayer.locations = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
            cellImageView.layer.addSublayer(cellColorsLayer)
        }
        
        return cell
    }
}

extension MainSettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isHighlighted = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isHighlighted = false
    }
}
