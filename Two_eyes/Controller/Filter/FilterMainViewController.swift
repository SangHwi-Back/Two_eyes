//
//  FilterMainViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/08/17.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit
import Photos

protocol FilterMainViewControllerTransitionDelegate {
    func performFilterSegue(identifier: String)
}

protocol FilterViewCell {
    static var reuseIdentifier: String { get }
}

class FilterMainViewController: UIViewController {

    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var filterImageViewA: UIImageView!
    @IBOutlet var filterImageViewAPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var filterImageViewB: UIImageView!
    @IBOutlet var filterImageViewBPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var initializeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var canvasView: UIView!
    
    
    var currentAsset: PHAsset!
    var imageManager: PHImageManager!
    var initialImage: UIImage!
    
    private var basicFilter: BasicFilterTemplate!
    
    // Constant
    private let filterNames = Constants.filterViewFilters
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInitialImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.basicFilter.delegate = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FilterAdjustViewController {
            
        }
    }
    
    @IBAction func initializeButtonTouchUpInside(_ sender: UIButton) {
        getInitialImage()
    }
    
    @IBAction func saveButtonTouchUpInside(_ sender: UIButton) {
        UIGraphicsBeginImageContextWithOptions(self.canvasView.frame.size, false, 0.0)
        self.canvasView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        
        UIGraphicsEndImageContext()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterImageViewPanGestureAction(_ sender: UIPanGestureRecognizer) {
        sendAction(recognizer: sender)
    }
    
    @IBAction func filterImageViewPinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        sendAction(recognizer: sender)
    }
    
    private func sendAction(recognizer: UIGestureRecognizer) {
        
        guard recognizer.view is UIImageView else {
            return
        }
        
        if let rec = recognizer as? UIPanGestureRecognizer {
            (recognizer.view as! UIImageView)
                .actionPanGesture(recognize: rec, in: self.canvasView)
        } else if let rec = recognizer as? UIPinchGestureRecognizer {
            (recognizer.view as! UIImageView)
                .actionPinchGesture(recognize: rec, in: self.canvasView)
        }
    }
    
    func getInitialImage() {
        
        imageManager.requestImage(for: currentAsset, targetSize: filterImageViewA.frame.size, contentMode: .aspectFit, options: nil) { [self] image, _ in
            
            if let image = image, let ciImage = CIImage(image: image) {
                
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
}

extension FilterMainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterNames.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        DispatchQueue.main.async {
            (collectionView.collectionViewLayout as? CarouselLayout)?.setupLayout()
        }
        
        let cell: FilterMainCollectionViewCell = collectionView.dequeReusableCell(for: indexPath)
        
        cell.delegate = self
        
        if indexPath.row == 0 || indexPath.row+1 == collectionView.numberOfItems(inSection: 0) {
            cell.filteredImageView.image = initialImage
            return cell
        }
        
        if let image = CIImage(image: initialImage) {
            
            basicFilter.filterName = filterNames[indexPath.row - 1]
            basicFilter.needToFilterCIImage = image
            cell.filteredImageView.image = UIImage(ciImage: basicFilter.filteredImage)
        }
        
        collectionView.contentSize.width += (collectionView.frame.width / 2 + 5.0)
        
        return cell
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let size = collectionView.cellForItem(at: IndexPath(row: 0, section: 0))?.frame.size
        return CGSize(width: (size?.width ?? 50) / 2, height: (size?.height ?? 50) / 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        let size = collectionView.cellForItem(at: IndexPath(row: 0, section: 0))?.frame.size
        return CGSize(width: (size?.width ?? 50) / 2, height: (size?.height ?? 50) / 2)
    }
}

extension FilterMainViewController: FilterMainViewControllerTransitionDelegate {
    func performFilterSegue(identifier: String) {
        performSegue(withIdentifier: identifier, sender: self)
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

private extension UICollectionView {
    
    func dequeReusableCell<T: FilterViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError()
        }
        
        return cell
    }
}
