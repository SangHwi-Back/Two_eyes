//
//  SettingsTableViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/11.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol SettingInterfaceBasicProtocol {
    var settingName: String { get set }
}

class SettingsTableViewController: UITableViewController {

    @IBOutlet var settingSearchBar: UISearchBar!
    private let themeManager = (UIApplication.shared.delegate as! AppDelegate).themeManager!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setTheme()
        tableView.reloadData()
        navigationItem.title = nil
        navigationItem.hidesBackButton = true
    }
    @IBAction func logoutButtonTouchUpInside(_ sender: UIButton) {
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.sections.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.settings[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if themeManager.getNavtabBackgroundColor() != UIColor.systemBackground {
            view.tintColor = themeManager.getNavtabBackgroundColor()
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = themeManager.getBodyTextColor()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier, for: indexPath)
        // Configure the cell...
        cell.textLabel?.text = Constants.settings[indexPath.section]
        
        if themeManager.getNavtabBackgroundColor() != UIColor.systemBackground {
            cell.textLabel?.textColor = themeManager.getBodyTextColor()
            cell.contentView.backgroundColor = themeManager.getThemeBackgroundColor()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let key = cell?.textLabel?.text ?? ""
        
        navigationItem.title = key
        if let key = Constants.settingsSegueIdentifier[key] {
            performSegue(withIdentifier: key, sender: self)
        }
        
        navigationItem.hidesBackButton = false
        cell?.isSelected = false
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? FilterSettingViewController {
            dest.settingName = segue.identifier?.getKey ?? ""
            self.navigationController?.title = "필터 설정"
        }
        
        if let dest = segue.destination as? CameraSettingViewController {
            dest.settingName = segue.identifier?.getKey ?? ""
            self.navigationController?.title = "카메라 설정"
        }
        
        if let dest = segue.destination as? PhotoLibrarySettingViewController {
            dest.settingName = segue.identifier?.getKey ?? ""
            self.navigationController?.title = "사진 검색 설정"
        }
        
        navigationItem.hidesBackButton = false
    }

}

extension String {
    var getKey: String {
        for (key, value) in Constants.settingsSegueIdentifier {
            if self == value {
                return key
            }
        }
        return ""
    }
}
