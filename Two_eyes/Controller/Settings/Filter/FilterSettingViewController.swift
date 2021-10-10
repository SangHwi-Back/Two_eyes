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
    var cellTitleArray: [String] = ["사진 필터 화면에서 원본 사진 보이기", "미세조정 값 추가 혹은 제거"]
    var cellTypeArray: [String] = ["Switch", "Switch"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitleArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let typeOfCell = cellTypeArray[indexPath.row]
        
        if typeOfCell.lowercased() == "slider" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterSettingSliderViewCell.cellIdentifier, for: indexPath) as? FilterSettingSliderViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: "FilterSettingSwitchViewCell", for: indexPath)
            }
            
            cell.contentsLabel.text = cellTitleArray[indexPath.row]
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterSettingSwitchViewCell.cellIdentifier, for: indexPath) as? FilterSettingSwitchViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: "FilterSettingSwitchViewCell", for: indexPath)
            }
            
            cell.contentsLabel.text = cellTitleArray[indexPath.row]
            
            return cell
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
}
