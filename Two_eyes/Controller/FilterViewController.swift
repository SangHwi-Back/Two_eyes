//
//  FilterViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/11.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import ChameleonFramework

class FilterViewController: UIViewController {
    
    //MARK: - Outlet 연결
    @IBOutlet weak var filteredImageView: UIImageView!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var canvasView: UIView!
    
    @IBOutlet weak var filterItemsCollectionView: UICollectionView!
    @IBOutlet weak var imageVariableScrollView: UIScrollView!
    
    @IBOutlet weak var imageVariableRootStack: UIStackView!
    @IBOutlet weak var imageVariableChildrenStack: UIStackView!
    
    @IBOutlet var filterImagePanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var capturedImagePanGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet var filterImagePinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet var capturedImagePinchGestureRecognizer: UIPinchGestureRecognizer!
    
    //MARK: - constants 생성
    let filters: [String] = [
        "none",
        "CIColorMonochrome",
        "CISepiaTone",
        "CIVignette"
    ]
    let adjustKey: [String] = [
        "blur",
        "brightness",
        "contrast",
        "opacity"
    ]
    var highlightedCollectionItemIndex: Int = 0
    var basicFilter = BasicFilterTemplate()
    var currentAsset: PHAsset?
    var imageManager: PHCachingImageManager?
    var initialImage: UIImage?
    var changedX: CGFloat?
    var changedY: CGFloat?
    var panRecognizedView: UIImageView?
    var translation: CGPoint?
    
    //MARK: - viewDidLoad 시작
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filterItemsCollectionView.backgroundColor = UIColor.flatSand()
        self.view.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: CGRect(origin: view.frame.origin, size: view.frame.size), andColors: [UIColor.flatSand(), UIColor.flatSandDark()])
        
        navigationController?.navigationBar.isHidden = false
        
        filterItemsCollectionView.delegate = self
        filterItemsCollectionView.dataSource = self
        filterItemsCollectionView.allowsSelection = true
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        filterItemsCollectionView.isScrollEnabled = true
        filterItemsCollectionView.collectionViewLayout = layout
        
        basicFilter.delegate = self
        
        imageVariableScrollView.delegate = self
        
        filteredImageView.isUserInteractionEnabled = true
        capturedImageView.isUserInteractionEnabled = true
        navigationItem.hidesBackButton = false
        
        self.capturedImagePanGestureRecognizer.maximumNumberOfTouches = 1
        self.filterImagePanGestureRecognizer.maximumNumberOfTouches = 1
        
        filteredImageView.layer.zPosition = 1
        registerPhoto()
        registerAdjust()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        basicFilter.wouldDelegateExecute = true
        basicFilter.filterName = filters[0]
        basicFilter.filteredImage = filteredImageView.image
    }
    
    func registerPhoto() {
        if let imageManager = imageManager, let currentAsset = currentAsset {
            imageManager.requestImage(for: currentAsset, targetSize: capturedImageView.frame.size, contentMode: .aspectFill, options: nil) { (image, _) in
                self.initialImage = image
                self.capturedImageView.image = image
                self.filteredImageView.image = image
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backItem?.title = "Back"
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "#ffcd3c")
    }
    
    deinit {
        navigationController?.navigationBar.isHidden = true
    }

    @IBAction func saveThePicture(_ sender: UIButton) {
        DispatchQueue.main.async {
            PHPhotoLibrary.shared().performChanges({
                if let image = self.capturedImageView.image {
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    
                    guard let addAssetRequest = PHAssetCollectionChangeRequest(for: PHAssetCollection()) else {
                        return
                    }
                    addAssetRequest.addAssets([request.placeholderForCreatedAsset!] as NSArray)
                }
            }, completionHandler: nil )
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filteredImagePinchAction(_ sender: UIPinchGestureRecognizer) {
        if filterImagePinchGestureRecognizer.scale * filteredImageView.frame.width <= canvasView.frame.width {
            filteredImageView.transform = filteredImageView.transform.scaledBy(x: filterImagePinchGestureRecognizer.scale, y: filterImagePinchGestureRecognizer.scale)
        }
        
        filterImagePinchGestureRecognizer.scale = 1.0
    }
    
    @IBAction func capturedImagePinchAction(_ sender: UIPinchGestureRecognizer) {
        if capturedImagePinchGestureRecognizer.scale * capturedImageView.frame.width <= canvasView.frame.width {
            capturedImageView.transform = capturedImageView.transform.scaledBy(x: capturedImagePinchGestureRecognizer.scale, y: capturedImagePinchGestureRecognizer.scale)
        }
        
        capturedImagePinchGestureRecognizer.scale = 1.0
    }
    
    
    @IBAction func filteredImagePanAction(_ sender: UIPanGestureRecognizer) {
        translation = filterImagePanGestureRecognizer.translation(in: filteredImageView)
        //getChangedX, getChanged implemented in extension UIImageView
        filteredImageView!.center = CGPoint(
            x: filteredImageView.getChangedX(from: filteredImageView, as: translation!, canvas: canvasView),
            y: filteredImageView.getChangedY(from: filteredImageView, as: translation!, canvas: canvasView))
        filterImagePanGestureRecognizer.setTranslation(CGPoint.zero, in: filteredImageView)
    }
    
    @IBAction func capturedImagePanAction(_ sender: UIPanGestureRecognizer) {
        translation = capturedImagePanGestureRecognizer.translation(in: capturedImageView)
        capturedImageView!.center = CGPoint(
            x: capturedImageView.getChangedX(from: capturedImageView, as: translation!, canvas: canvasView),
            y: capturedImageView.getChangedY(from: capturedImageView, as: translation!, canvas: canvasView))
        capturedImagePanGestureRecognizer.setTranslation(CGPoint.zero, in: capturedImageView)
    }
    
    func registerAdjust() {
        for i in 0 ..< adjustKey.count {
            for subView in (imageVariableRootStack.arrangedSubviews.last as! UIStackView).arrangedSubviews {
                if subView is UITextField {
                    (subView as! UITextField).text = adjustKey[i]
                    (subView as! UITextField).allowsEditingTextAttributes = false
                }
                if subView is UISlider {
                    (subView as! UISlider).isEnabled = true
                    (subView as! UISlider).tag = i
                    (subView as! UISlider).addTarget(self, action: #selector(adjustValue), for: .valueChanged)
                }
            }
            if let copyView = imageVariableChildrenStack.copy() as? UIStackView {
                imageVariableRootStack.addArrangedSubview(copyView)
            }
        }
    }
    
    @objc func adjustValue(sender:UISlider) {
        basicFilter.adjustKey = adjustKey[sender.tag]
        basicFilter.adjustValue = sender.value
        
        DispatchQueue.main.async {
            self.basicFilter.preAdjustedImage = UIImage(image: self.initialImage!, scaledTo: self.filteredImageView.frame.size)
            self.filteredImageView.image = self.basicFilter.filteredImage
        }
    }
}

//MARK: - UICollectionView Methods
extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.cellForItem(at: indexPath)?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        basicFilter.wouldDelegateExecute = true
        basicFilter.filterName = filters[indexPath.row]
        basicFilter.preFilteredImage = capturedImageView.image
        filteredImageView.image = basicFilter.filteredImage
        initialImage = basicFilter.filteredImage
        filterItemsCollectionView.cellForItem(at: indexPath)?.alpha = 0.5
        
        for subStackView in imageVariableRootStack.subviews {
            for case let slider as UISlider in subStackView.subviews {
                slider.value = 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.alpha = 1.0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterItems", for: indexPath)
        basicFilter.wouldDelegateExecute = false
        basicFilter.filterName = filters[indexPath.row]
        basicFilter.preFilteredImage = initialImage
        cell.backgroundView = UIImageView(image: basicFilter.filteredImage)
        return cell
    }
    
}

extension FilterViewController: UIScrollViewDelegate {
    
}

extension UIStackView: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! UIStackView
        } catch {
            print("error in stackView ::: \(error)")
        }
        
        return UIStackView()
    }
}

extension FilterViewController {
    func copyView(viewForCopy: UIView) -> UIView? {
        viewForCopy.isHidden = false
        let viewCopy = viewForCopy.snapshotView(afterScreenUpdates: true)
        viewForCopy.isHidden = true
        return viewCopy
    }
}

extension FilterViewController: BasicFilterTemplageDelegate {
    func filterChange(as image: UIImage?, for filter: String) {
    }
    
    func adjustingValueChange(as image: UIImage?, using adjustKey: String, for adjustVal: Float) {
    }
}

extension FilterViewController: UITextFieldDelegate {
    //return 키 누르면 텍스트 닫힘.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
}

//MARK: - UIImageView extension
extension UIImageView {
    func getChangedX(from view: UIImageView, as translation: CGPoint, canvas: UIView) -> CGFloat {
        if (view.center.x + translation.x) <= canvas.frame.width {
            return view.center.x + translation.x
        }else if (view.center.x - translation.x) <= 0{
            return 0
        }else{
            return view.frame.width
        }
    }
    
    func getChangedY(from view: UIImageView, as translation: CGPoint, canvas: UIView) -> CGFloat {
        if (view.center.y + translation.y) <= canvas.frame.height {
            return view.center.y + translation.y
        }else if (view.center.y - translation.y) <= 0{
            return 0
        }else{
            return canvas.frame.height
        }
    }
}
