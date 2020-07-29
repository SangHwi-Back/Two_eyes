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
    let filters: [String] = Constants.filterViewFilters
    let adjustKey: [String] = Constants.filterViewAdjustKeys
    var highlightedCollectionItemIndex: Int = 0
    var basicFilter = BasicFilterTemplate()
    var currentAsset: PHAsset?
    var imageManager: PHCachingImageManager?
    var initialImage: UIImage?
    
    //MARK: - Methods executed in view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filterItemsCollectionView.backgroundColor = UIColor.flatSand()
        self.view.backgroundColor = UIColor(
            gradientStyle: UIGradientStyle.topToBottom,
            withFrame: CGRect(origin: view.frame.origin, size: view.frame.size),
            andColors: [UIColor.flatSand(), UIColor.flatSandDark()]
        )
        
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
        
        registerPhoto()
        registerAdjust()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Gesture source Start
        filteredImageView.isUserInteractionEnabled = true
        capturedImageView.isUserInteractionEnabled = true
        
        self.capturedImagePanGestureRecognizer.maximumNumberOfTouches = 1
        self.filterImagePanGestureRecognizer.maximumNumberOfTouches = 1
        
        filteredImageView.layer.zPosition = 0
        capturedImageView.layer.zPosition = 1
        canvasView.layer.zPosition = 2
        // Gesture source End
        
        basicFilter.wouldDelegateExecute = true
        basicFilter.filterName = filters[0]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func filteredImagePinchAction(_ sender: UIPinchGestureRecognizer) {
        filteredImageView.actionPinchGesture(recognize: sender, in: canvasView)
    }
    
    @IBAction func capturedImagePinchAction(_ sender: UIPinchGestureRecognizer) {
        capturedImageView.actionPinchGesture(recognize: sender, in: canvasView)
    }
    
    
    @IBAction func filteredImagePanAction(_ sender: UIPanGestureRecognizer) {
        filteredImageView.actionPanGesture(recognize: sender, in: canvasView)
    }
    
    @IBAction func capturedImagePanAction(_ sender: UIPanGestureRecognizer) {
        capturedImageView.actionPanGesture(recognize: sender, in: canvasView)
    }
}

//MARK: - Filtering methods
extension FilterViewController {    
    func registerPhoto() {
        basicFilter.filterName = filters[0]
        
        if initialImage != nil {
            capturedImageView.image = initialImage
            filteredImageView.image = initialImage
        }
        
        if let imageManager = imageManager, let currentAsset = currentAsset {
            imageManager.requestImage(for: currentAsset, targetSize: capturedImageView.frame.size, contentMode: .aspectFit, options: nil) { (image, _) in
                self.initialImage = image
                self.capturedImageView.image = image
                self.filteredImageView.image = image
            }
        }
    }

    @IBAction func saveThePicture(_ sender: UIButton) {
        UIGraphicsBeginImageContextWithOptions(self.canvasView.frame.size, false, 0.0)
        self.canvasView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        
        UIGraphicsEndImageContext()
        self.navigationController?.popViewController(animated: true)
    }
    
    func registerAdjust() {
        let subViews = (imageVariableRootStack.arrangedSubviews.last as! UIStackView).arrangedSubviews
        
        for i in 0 ..< adjustKey.count {
            for subView in subViews {
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
            
            imageVariableRootStack
                .addArrangedSubview(imageVariableChildrenStack.copy() as! UIStackView)
        }
    }
    
    @objc func adjustValue(sender:UISlider) {
        basicFilter.adjustKey = adjustKey[sender.tag]
        basicFilter.adjustValue = sender.value
        
        DispatchQueue.main.async {
            self.basicFilter.preAdjustedImage =
                UIImage(image: self.initialImage!, scaledTo: self.filteredImageView.frame.size)
            self.filteredImageView.image = self.basicFilter.filteredImage
        }
    }
}

//MARK: - UICollectionView Methods
extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        basicFilter.filterName = filters[indexPath.row]
        basicFilter.preFilteredImage = initialImage
        
        filteredImageView.image = basicFilter.filteredImage
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

extension FilterViewController: UIScrollViewDelegate {}

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
    func filterChange(as image: UIImage?, for filter: String) { }
    func adjustingValueChange(as image: UIImage?, using adjustKey: String, for adjustVal: Float) { }
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
    func actionPanGesture(recognize gesture: UIPanGestureRecognizer, in canvas: UIView) {
        let translation = gesture.translation(in: self)
        self.center = CGPoint(
            x: self.getChangedX(from: self, as: translation, canvas: canvas),
            y: self.getChangedY(from: self, as: translation, canvas: canvas)
        )
        
        gesture.setTranslation(CGPoint.zero, in: self) //initialize
    }
    
    func actionPinchGesture(recognize gesture: UIPinchGestureRecognizer, in canvas: UIView) {
        if gesture.scale * self.frame.width <= canvas.frame.width {
            self.transform = self.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        }
        
        gesture.scale = 1.0 //initialize
    }
    
    func getChangedX(from view: UIImageView, as translation: CGPoint, canvas: UIView) -> CGFloat {
        if (view.center.x + translation.x) <= canvas.frame.width {
            return view.center.x + translation.x
        }else if (view.center.x - translation.x) <= 0{
            return 0
        }
        
        return view.frame.width
    }
    
    func getChangedY(from view: UIImageView, as translation: CGPoint, canvas: UIView) -> CGFloat {
        if (view.center.y + translation.y) <= canvas.frame.height {
            return view.center.y + translation.y
        }else if (view.center.y - translation.y) <= 0{
            return 0
        }
        
        return canvas.frame.height
    }
    
}
