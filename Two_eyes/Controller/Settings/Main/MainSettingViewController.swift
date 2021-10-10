//
//  MainSettingViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/08/21.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase

protocol MainSettingDelegate {
    func delegateSegue(identifier: String)
    func delegateShow()
}

class MainSettingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var initiateButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    var cellSize = CGSize()
    var cellLabelSize = CGSize()
    var cellImageViewSize = CGSize()
    var selectedCellId: String?
    
    let choosedTheme = UserDefaults.standard.value(forKey: "MainTheme") ?? "Egg_Tart"
    let container = NSPersistentContainer(name: Constants.themeEntityName)
    let saveAlertController = UIAlertController(title: "테마 저장", message: "정말로 테마를 저장하시겠습니까?", preferredStyle: .alert)
    let successAlertController = UIAlertController(title: "알림", message: "테마가 정상적으로 적용되었습니다.", preferredStyle: .alert)
    
//    private var themeManager: ThemeManager?
    private var themeModel: ThemeInfoModel?
    private var databaseRef: DatabaseReference?
    private var themeList: [ThemeInfo]? { didSet { tableView.reloadData() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 10
        initiateButton.layer.cornerRadius = 10
        
        alertControllerInitializer()
        
//        themeManager = (UIApplication.shared.delegate as? AppDelegate)?.themeManager
        themeModel = (UIApplication.shared.delegate as? AppDelegate)?.themeModel
        databaseRef = (UIApplication.shared.delegate as? AppDelegate)?.databaseRef
        
        if let ref = databaseRef {
            
            ref.child("ThemeInfo").getData { error, snapshot in
                guard error == nil, snapshot.exists() else {
                    print("[ERROR Occured in theme] ::: \(String(describing: error))");return;
                }
                
                let value = snapshot.value as? [Dictionary<String, String>]
                let data = value?.jsonData
                
                if let data = data, let list = try? JSONDecoder().decode([ThemeInfo].self, from: data) {
                    self.themeList = list
                    self.themeModel?.infoItems = list
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTheme()
    }
    
    @IBAction func initiateButtonTouchUpInside(_ sender: UIButton) {
        
        let data = themeModel?.defaultThemeInfo ?? Constants.applicationDefaultThemesHEX[0]
        themeModel?.setDefaultThemeInfo(themeInfo: data)
    }
    
    @IBAction func saveButtonTouchUpInside(_ sender: UIButton) {
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

extension MainSettingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainSettingTableViewCell", for: indexPath) as! MainSettingTableViewCell
        
        guard let data = themeList?[indexPath.row] else {
            return cell
        }
        
        cell.info = data
        cell.contentsLabel.text = data.contents
        cell.stackColors()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        themeList?.count ?? 0
    }
}

extension MainSettingViewController: MainSettingDelegate {
    func delegateSegue(identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
    }
    
    func delegateShow() {
        self.show(MainSettingPageViewController(), sender: self)
    }
}

extension Collection {
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
}
