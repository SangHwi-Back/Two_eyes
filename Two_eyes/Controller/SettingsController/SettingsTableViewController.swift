//
//  SettingsTableViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/11.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol SettingInterfaceBasicProtocol {
    var settingName: String { get set }
}

class SettingsTableViewController: UITableViewController {

    @IBOutlet var settingSearchBar: UISearchBar!
    var ancestorNavigationBar: UINavigationBar?
    var ancestorNavigationItem: UINavigationItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom,
                                                 withFrame: CGRect(origin: view.frame.origin, size: view.frame.size),
                                                 andColors: [UIColor.flatSand(), UIColor.flatSandDark()])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier, for: indexPath)
        // Configure the cell...
        cell.textLabel?.text = Constants.settings[indexPath.section]
        cell.backgroundColor = UIColor.flatSand()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let key = cell?.textLabel?.text ?? ""
        
        navigationController?.navigationItem.title = key
        cell?.isSelected = false
        if let key = Constants.settingsSegueIdentifier[key] {
            performSegue(withIdentifier: key, sender: self)
        }
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? FilterSettingViewController {
            dest.settingName = segue.identifier?.getKey ?? ""
            dest.ancestorNavigationItem = self.ancestorNavigationItem
            dest.ancestorNavigationBar = self.ancestorNavigationBar
        }
        
        if let dest = segue.destination as? CameraSettingViewController {
            dest.settingName = segue.identifier?.getKey ?? ""
            dest.ancestorNavigationItem = self.ancestorNavigationItem
            dest.ancestorNavigationBar = self.ancestorNavigationBar
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
