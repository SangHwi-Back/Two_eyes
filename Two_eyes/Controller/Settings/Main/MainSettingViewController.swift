//
//  MainSettingViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/08/21.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth

class MainSettingViewController: UIViewController {
    
    @IBOutlet weak var themeChooserCollectionView: UICollectionView!
    @IBOutlet var saveThemeKey: UIButton!
    @IBOutlet var logout: UIButton!
    
    var cellSize = CGSize()
    var cellLabelSize = CGSize()
    var cellImageViewSize = CGSize()
    var selectedCellId: String?
    
    let choosedTheme = UserDefaults.standard.value(forKey: "MainTheme") ?? "Egg_Tart"
    let container = NSPersistentContainer(name: Constants.themeEntityName)
    let saveAlertController = UIAlertController(title: "테마 저장", message: "정말로 테마를 저장하시겠습니까?", preferredStyle: .alert)
    let successAlertController = UIAlertController(title: "알림", message: "테마가 정상적으로 적용되었습니다.", preferredStyle: .alert)
    
    private let themeManager = (UIApplication.shared.delegate as! AppDelegate).themeManager!
    
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
        
        saveThemeKey.layer.cornerRadius = 10
        logout.layer.cornerRadius = 10
        
        themeChooserCollectionView.delegate = self
        themeChooserCollectionView.dataSource = self
        themeChooserCollectionView.register(UINib(nibName: "MainSettingViewCell", bundle: nil), forCellWithReuseIdentifier: "mainSettingViewCell")
        themeChooserCollectionView.awakeFromNib()
        themeChooserCollectionView.allowsSelection = true
        themeChooserCollectionView.setCollectionViewLayout(layout, animated: true)
        themeChooserCollectionView.reloadData()
        
        alertControllerInitializer()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTheme()
    }
    
    @IBAction func logoutInAction(_ sender: UIButton) {
        let scenedelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = mainStoryboard.instantiateViewController(identifier: "initialView")
        
        do {
            try Auth.auth().signOut()
            scenedelegate.window?.rootViewController = mainVC
            scenedelegate.window?.makeKeyAndVisible()
        } catch {
            print(error)
        }
    }
    @IBAction func saveThemeInAction(_ sender: UIButton) {
        self.present(self.saveAlertController, animated: true)
    }
    
    private func alertControllerInitializer() {
        let positiveAction = UIAlertAction(title: "예", style: .default) { _ in
            UserDefaults.standard.set(self.selectedCellId ?? "Default", forKey: "MainTheme")
        }
        let negativeAction = UIAlertAction(title: "아니요", style: .cancel)
        
        self.saveAlertController.addAction(positiveAction)
        self.saveAlertController.addAction(negativeAction)
        
        let confirmAction = UIAlertAction(title: "확인", style: .cancel)
        self.successAlertController.addAction(confirmAction)
    }
}

extension MainSettingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Constants.applicationThemeNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainSettingViewCell", for: indexPath) as? MainSettingViewCell,
            let storedThemes = self.themeManager.storedThemes else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainSettingViewCell", for: indexPath)
            cell.frame = CGRect(x: 0, y: 0, width: 150, height: 180)
            cell.backgroundColor = .black
            return cell
        }
        
        let themeName = Constants.applicationThemeNames[indexPath.row]
        let themeInfo = storedThemes.filter { $0.id == themeName }.first!
        
        cell.label.text = themeName
        cell.themeName = themeName
        cell.themeInfo = themeInfo
        
        for (index, imageView) in cell.imageViewStack.subviews.enumerated() where imageView is UIImageView {
            if themeName == "Default" {
                continue
            }
            
            if let colorString = themeInfo.value(forKey: Constants.themeKeys[index]) as? String {
                imageView.backgroundColor = colorString.toUIColor
            }
            imageView.layer.borderWidth = 0.5
            imageView.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1.0)
        }
        
        return cell
    }
}

extension MainSettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MainSettingViewCell,
            let themeInfo = cell.themeInfo else {
            return
        }
        
        cell.isSelected = true
        
        themeManager.setSelectedThemeKey(themeInfo.id)
        themeManager.applyTheme()
        
        self.selectedCellId = themeInfo.id
        
        self.present(self.successAlertController, animated: true) {
            self.view.setNeedsDisplay()
            self.view.setNeedsLayout()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MainSettingViewCell else {
            return
        }
        
        cell.isSelected = false
        
        themeManager.setSelectedThemeKey("Default")
        themeManager.applyTheme()
    }
}
