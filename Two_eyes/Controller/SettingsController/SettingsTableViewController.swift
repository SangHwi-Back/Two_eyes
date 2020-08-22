//
//  SettingsTableViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/11.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit

protocol SettingInterfaceBasicProtocol {
    var settingName: String { get set }
}

class SettingsTableViewController: UITableViewController {

    @IBOutlet var settingSearchBar: UISearchBar!

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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier, for: indexPath)
        // Configure the cell...
        cell.textLabel?.text = Constants.settings[indexPath.section]
        return cell
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
        }
        
        if let dest = segue.destination as? CameraSettingViewController {
            dest.settingName = segue.identifier?.getKey ?? ""
        }
        
        if let dest = segue.destination as? PhotoLibrarySettingViewController {
            dest.settingName = segue.identifier?.getKey ?? ""
        }
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
