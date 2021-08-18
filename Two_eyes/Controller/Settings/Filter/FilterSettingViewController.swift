//
//  FilterSettingViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/07/29.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit

class FilterSettingViewController: UITableViewController, SettingInterfaceBasicProtocol {
    var settingName: String = ""
    var cellReuseIdentifier: String? {
        get{
            Constants.settingsCellReuseIdentifier[settingName]
        }
    }
    var cellTitles: [String] {
        get{
            Constants.settingsCellTitles[settingName] ?? []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cellReuseIdentifier = cellReuseIdentifier {
            tableView.register(UINib(nibName: "FilterSettingViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationItem.title = nil
        navigationItem.hidesBackButton = true
    }
    
    @objc func movePrev() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier ?? "", for: indexPath) as? FilterSettingViewCell else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier ?? "", for: indexPath)
            cell.textLabel?.text = cellTitles[indexPath.row]
            return cell
        }
        
        cell.filterSettingLabel.text = cellTitles[indexPath.row]
        cell.filterSettingSlider.isHidden = true
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
}
