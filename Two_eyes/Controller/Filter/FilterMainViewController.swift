//
//  FilterMainViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/08/17.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit
import Photos

class FilterMainViewController: UIViewController {

    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet var filterCollectionViewTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var filterImageViewA: UIImageView!
    @IBOutlet weak var filterImageViewB: UIImageView!
    @IBOutlet weak var initializeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var currentAsset: PHAsset!
    var imageManager: PHImageManager!
    var initialImage: UIImage!
    
    private var basicFilter: BasicFilterTemplate!
    
    // Constant
    private let filterNames = Constants.filterViewFilters
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageManager.requestImage(for: currentAsset, targetSize: filterImageViewA.frame.size, contentMode: .aspectFit, options: nil) { [self] image, _ in
            
            if let image = image, let ciImage = CIImage(image: initialImage) {
                
                initialImage = image
                basicFilter = BasicFilterTemplate(image: ciImage)
                basicFilter.filterName = filterNames.first!
                basicFilter.delegate = self
                
                filterImageViewA.image = UIImage(ciImage: basicFilter.filteredImage)
                filterImageViewB.image = UIImage(ciImage: basicFilter.filteredImage)
                
            } else {
                fatalError("paramImage NIL!!!")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.basicFilter.delegate = nil
    }
    
    @objc func tapFilterCollectionViewCell(_ sender: Any?) {
        performSegue(withIdentifier: "FilterAdjustViewController", sender: sender)
    }
    
    @IBAction func initializeButtonTouchUpInside(_ sender: UIButton) {
    }
    
    @IBAction func saveButtonTouchUpInside(_ sender: UIButton) {
    }
}

extension FilterMainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.cellForItem(at: indexPath)!
        
        filterCollectionViewTapGesture.addTarget(cell, action: #selector(tapFilterCollectionViewCell(_:)))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        filterCollectionViewTapGesture.removeTarget(cell, action: #selector(tapFilterCollectionViewCell(_:)))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let criterion = collectionView.frame.size.height
        return CGSize(width: criterion, height: criterion)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5.0
    }
}

extension FilterMainViewController: UICollectionViewDelegate {
    
}

extension FilterMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var id = ""
        
        if kind == UICollectionView.elementKindSectionFooter {
            id = "FilterMainHeaderCollectionView"
        } else if kind == UICollectionView.elementKindSectionHeader {
            id = "FilterMainFooterCollectionView"
        }
        
        let supplementaryElement = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath)
        
        return supplementaryElement
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let size = collectionView.cellForItem(at: IndexPath(row: 0, section: 0))?.frame.size
        return CGSize(width: (size?.width ?? 50) / 2, height: (size?.height ?? 50) / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        let size = collectionView.cellForItem(at: IndexPath(row: 0, section: 0))?.frame.size
        return CGSize(width: (size?.width ?? 50) / 2, height: (size?.height ?? 50) / 2)
    }
}

extension FilterMainViewController: BasicFilterTemplageDelegate {
    func afterFilterChanged(as image: CIImage, for filterKey: String) {
        guard let cgImage = image.cgImage else { return }
        filterImageViewB.image = UIImage(cgImage: cgImage)
    }
    
    func afterAdjustingValueChange(as image: CIImage, using adjustKey: FilterAdjustKey, for adjustVal: Float) {
        guard let cgImage = image.cgImage else { return }
        filterImageViewB.image = UIImage(cgImage: cgImage)
    }
}
