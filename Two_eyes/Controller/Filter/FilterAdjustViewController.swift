//
//  FilterAdjustViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/08/18.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit
import Photos

class FilterAdjustViewController: UIViewController {
    
    @IBOutlet weak var adjustImageView: UIImageView!
    @IBOutlet weak var adjustTableView: UITableView!
    
    var imageViewModel: FilterImageViewModel!
    var filterName = "none"
    
    var adjustInfos: [String: CGFloat]! = Dictionary(uniqueKeysWithValues: Constants.filterViewAdjustKeys.map{($0, 0.0)})
    var adjustkeys = Constants.filterViewAdjustKeys
    var maxLabelWidth: CGFloat = 0.0 {
        didSet {
            DispatchQueue.main.async {
                (self.adjustTableView.visibleCells as? [FilterAdjustTableViewCell])?.forEach({ cell in
                    cell.labelWidth.constant = self.maxLabelWidth
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if imageViewModel == nil {
            self.navigationController?.popViewController(animated: true)
        }
        
        var imageSize = adjustImageView.frame.size
        imageSize.width -= 32
        imageSize.height -= 32
        
        imageViewModel.requestFilteredImage(size: imageSize, filterName: filterName) { image in
            DispatchQueue.main.async { [self] in
                adjustImageView.image = image
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        let alert = UIAlertController(title: "경고", message: "내부 오류가 발생하였습니다.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(confirmAction)
        
        self.navigationController?.pushViewController(alert, animated: true)
    }
}

extension FilterAdjustViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        adjustInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterAdjustTableViewCell") as! FilterAdjustTableViewCell
        
//        if indexPath.row+1 == tableView.numberOfRows(inSection: 0) {
//            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
//        } else {
//            tableView.scrollToRow(at: IndexPath(row: indexPath.row+1, section: 0), at: .bottom, animated: false)
//        }
        
//        if indexPath.row+1 != tableView.numberOfRows(inSection: 0) {
//            tableView.scrollToRow(at: IndexPath(row: indexPath.row+1, section: 0), at: .bottom, animated: false)
//        }
        
        cell.nameLabel.text = adjustkeys[indexPath.row]
        cell.valueSlider.value = Float(adjustInfos[adjustkeys[indexPath.row]] ?? 0.0)
        
        if maxLabelWidth < cell.nameLabel.frame.width {
            maxLabelWidth = cell.nameLabel.frame.width
        }
        
        return cell
    }
}

extension FilterAdjustViewController: UITableViewDelegate {
    
}
