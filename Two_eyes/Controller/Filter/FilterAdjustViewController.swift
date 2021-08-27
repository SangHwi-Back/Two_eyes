//
//  FilterAdjustViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/08/18.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit
import Photos

protocol FilterAdjustDelegate {
    func valueSliderChanged(key: FilterAdjustKey, value: Float)
}

class FilterAdjustViewController: UIViewController {
    
    @IBOutlet weak var adjustImageView: UIImageView!
    @IBOutlet weak var adjustTableView: UITableView!
    
    var initiallyRequestedImage: UIImage?
    var imageViewModel: FilterImageViewModel!
    var filterName = "none"
    
    var adjustInfos: [FilterAdjustKey: CGFloat] = Dictionary(FilterAdjustKey.allCases.compactMap { $0 }.map { ($0, 0.0) }, uniquingKeysWith: { first, _ in return first })

    var adjustKeys = FilterAdjustKey.allCases
    var maxLabelWidth: CGFloat = 0.0
    
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
                initiallyRequestedImage = image
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        let alert = UIAlertController(title: "경고", message: "내부 오류가 발생하였습니다.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(confirmAction)
        
        self.navigationController?.pushViewController(alert, animated: true)
    }
    
    func updateAllVisibleCells() {
        DispatchQueue.main.async {
            (self.adjustTableView.visibleCells as? [FilterAdjustTableViewCell])?.forEach({ cell in
                cell.labelWidth.constant = self.maxLabelWidth
            })
        }
    }
}

extension FilterAdjustViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        adjustInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterAdjustTableViewCell") as! FilterAdjustTableViewCell
        
        cell.adjustKey = adjustKeys[indexPath.row]
        cell.valueSlider.value = Float(adjustInfos[adjustKeys[indexPath.row]] ?? 0.0)
        cell.delegate = self
        
        cell.setNeedsDisplay()
        cell.layoutIfNeeded()
        if maxLabelWidth < cell.nameLabel.frame.width {
            maxLabelWidth = cell.nameLabel.frame.width
        }
        updateAllVisibleCells()
        
        return cell
    }
}

extension FilterAdjustViewController: UITableViewDelegate {
}

extension FilterAdjustViewController: FilterAdjustDelegate {
    func valueSliderChanged(key: FilterAdjustKey, value: Float) {
        guard let image = initiallyRequestedImage else { return }
        DispatchQueue.global().async {
            self.imageViewModel
                .adjustingFilteredImage(
                    key: key, value: value, image: image
                ) { image in
                    DispatchQueue.main.async {
                        self.adjustImageView.image = image
                    }
                }
        }
    }
}
