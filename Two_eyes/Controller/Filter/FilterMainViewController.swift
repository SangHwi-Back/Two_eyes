//
//  FilterMainViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/08/17.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit
import Photos

protocol FilterMainViewTransitionDelegate {
    func performFilterSegue(identifier: String, sender: Any)
}

protocol FilterAdjustViewDelegate {
    func afterDismissViewController(resultImage: UIImage?)
}

protocol FilterViewCell {
    static var reuseIdentifier: String { get }
    var asset: PHAsset? { get set }
    var filterName: String? { get set }
}

class FilterMainViewController: UIViewController {

    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var filterImageViewA: FilterImageView!
    @IBOutlet var filterImageViewAPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var filterImageViewB: FilterImageView!
    @IBOutlet var filterImageViewBPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var initializeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var canvasView: UIView!
    
    var currentAsset: PHAsset!
    var imageManager: PHImageManager!
    var initialImage: UIImage!
    
    private var basicFilter: BasicFilterTemplate!
    private var imageViewModel: FilterImageViewModel!
    
    // Constant
    private let filterNames = Constants.filterViewFilters.filter({$0 != "none"})
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if initialImage == nil {
            
            imageManager.requestImage(for: currentAsset, targetSize: filterImageViewB.frame.size, contentMode: .aspectFit, options: nil) { [self] result, _ in
                imageViewModel = FilterImageViewModel(asset: currentAsset, manager: imageManager, image: CIImage(image: result!)!)
            }
            
        } else {
            imageViewModel = FilterImageViewModel(asset: currentAsset, manager: imageManager, image: CIImage(image: initialImage)!)
        }
        
        getInitialImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? FilterAdjustViewController {
            dest.imageViewModel = self.imageViewModel
            dest.delegate = self
            
            if let cell = sender as? FilterViewCell {
                dest.filterName = cell.filterName ?? "none"
            }
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
        DispatchQueue.global().async { [self] in
            if let gestureView = sender.view as? FilterImageView {
                gestureView.actionPanGesture(recognize: sender, in: canvasView) {
                    if gestureView.filterName != "none" {
                        admitRequestedFilteredImage(targetView: gestureView, filterName: gestureView.filterName)
                    } else {
                        admitRequestedAssetImage(targetView: gestureView)
                    }
                }
            }
        }
    }
    
    @IBAction func filterImageViewPinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        DispatchQueue.global().async { [self] in
            if let gestureView = sender.view as? FilterImageView {
                gestureView.actionPinchGesture(recognize: sender, in: canvasView) {
                    if gestureView.filterName != "none" {
                        admitRequestedFilteredImage(targetView: gestureView, filterName: gestureView.filterName)
                    } else {
                        admitRequestedAssetImage(targetView: gestureView)
                    }
                }
            }
        }
    }
    
    func getInitialImage() {
        admitRequestedAssetImage(targetView: filterImageViewA)
        admitRequestedAssetImage(targetView: filterImageViewB)
    }
    
    func admitRequestedAssetImage(targetView: FilterImageView) {
        imageViewModel.requestAssetImage(size: targetView.frame.size) { image in
            DispatchQueue.main.async { targetView.image = image }
        }
    }
    
    func admitRequestedFilteredImage(targetView: FilterImageView, filterName: String? = nil) {
        imageViewModel.requestFilteredImage(
            size: targetView.frame.size,
            filterName: filterName != nil ? filterName! : targetView.filterName)
        { image in
            DispatchQueue.main.async {
                targetView.image = image
            }
        }
    }
}

extension FilterMainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterNames.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: FilterMainCollectionViewCell = collectionView.dequeReusableCell(for: indexPath)
        let filterNameIndex = indexPath.row == 0 || indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 ? 0 : indexPath.row - 1
        
        collectionView.contentSize.width += (collectionView.frame.width / 2 + 5.0)
        
        cell.delegate = self
        cell.asset = self.currentAsset
        cell.filteredImageView.filterName = filterNames[filterNameIndex]
        cell.filterName = filterNames[filterNameIndex]
        
        admitRequestedFilteredImage(targetView: cell.filteredImageView)
        
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        if let target = (cell as? FilterMainCollectionViewCell)?.filteredImageView {
            filterImageViewB.filterName = target.filterName
            self.admitRequestedFilteredImage(
                targetView: filterImageViewB,
                filterName: target.filterName
            )
        }
    }
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

extension FilterMainViewController: FilterMainViewTransitionDelegate {
    func performFilterSegue(identifier: String, sender: Any) {
        performSegue(withIdentifier: identifier, sender: sender)
    }
}

extension FilterMainViewController: FilterAdjustViewDelegate {
    func afterDismissViewController(resultImage: UIImage?) {
        self.filterImageViewB.image = resultImage
        FlashMessage(self, message: "수정한 이미지를 적용하였습니다.").show()
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
