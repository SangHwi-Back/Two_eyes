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

class FilterViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    //MARK: - Outlet 연결
    private var capturedViewLabel = UILabel()
    private var filteredViewLabel = UILabel()
    
    @IBOutlet weak var filteredImageView: UIImageView!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var canvasView: UIView!
    
    @IBOutlet weak var filterItemsCollectionView: UICollectionView!
    
    @IBOutlet weak var filterImagePanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var capturedImagePanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var filterImagePinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var capturedImagePinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var modalBackgroundTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var adjustRootStackView: UIStackView!
    
    //MARK: - constants 생성
    private let filters: [String] = Constants.filterViewFilters
    private let coordinator = FilterViewCoordinator()
    private var highlightedCollectionItemIndex: Int = 0
    private var basicFilter: BasicFilterTemplate!
    
    var currentAsset: PHAsset?
    var imageManager: PHCachingImageManager?
    var initialImage: UIImage!
    var initialCIImage: CIImage!
    var filteredImage: UIImage?
    
    //MARK: - Methods executed in view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        
        registerPhoto() // including self.basicFilter
        self.basicFilter.delegate = self
        coordinatorSetting()
        self.capturedImageView.image = self.initialImage
        self.filteredImageView.image = self.initialImage
        
        setTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        filteredViewLabel.text = "필터이미지"
        filteredViewLabel.textAlignment = .center
        filteredViewLabel.textColor = .white
        capturedViewLabel.text = "원본"
        capturedViewLabel.textAlignment = .center
        capturedViewLabel.textColor = .white
        
        // Gesture source Start
        self.filteredImageView.isUserInteractionEnabled = true
        self.capturedImageView.isUserInteractionEnabled = true
        
        self.filteredImageView.addSubview(filteredViewLabel)
        self.capturedImageView.addSubview(capturedViewLabel)
        
        filteredViewLabel.frame = filteredImageView.frame
        capturedViewLabel.frame = capturedImageView.frame
        
        self.capturedImageView.layer.zPosition = 1
        self.filteredImageView.layer.zPosition = 2
        self.canvasView.layer.zPosition = 0
        self.adjustRootStackView.layer.zPosition = 3
        // Gesture source End
        
        basicFilter.wouldDelegateExecute = true
        basicFilter.filterName = filters[0]
    }
    
    deinit {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func coordinatorSetting() {
        //modalMasterView
        coordinator.modalMasterView = self
        
        //modal(Detail)View
        coordinator.modalView = AdjustModalViewController(coordinator: coordinator, adjustKeys: self.basicFilter.filterViewAdjustKey)
        coordinator.modalView.modalPresentationStyle = .custom
        coordinator.modalView.isModalInPresentation = true
        coordinator.modalView.transitioningDelegate = self
        coordinator.canvasSize = self.canvasView.bounds.size
        
        //canvasView : missing. no need.
    }
    
    @IBAction func imageViewZIndexChange(_ sender: UISegmentedControl) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                if sender.selectedSegmentIndex == 0 {
                    self.filteredImageView.layer.zPosition = 1
                    self.capturedImageView.layer.zPosition = 0
                } else {
                    self.filteredImageView.layer.zPosition = 0
                    self.capturedImageView.layer.zPosition = 1
                }
            }
        }
    }
    
    @IBAction func imageViewLabelHidden(_ sender: UISegmentedControl) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                if sender.selectedSegmentIndex == 0 {
                    self.filteredViewLabel.alpha = 1
                    self.capturedViewLabel.alpha = 1
                } else {
                    self.filteredViewLabel.alpha = 0
                    self.capturedViewLabel.alpha = 0
                }
            }
        }
    }
    
    @IBAction func filterCombinationActivate(_ sender: UISegmentedControl) {
        self.basicFilter.combinationActivated = (sender.selectedSegmentIndex == 0)
        self.filteredImageView.image = self.initialImage // initialize filteredImageView
        self.coordinator.modalView.adjustValueToZero()
    }
    
    @IBAction func filteredImagePinchAction(_ sender: UIPinchGestureRecognizer) {
//        self.filteredImageView.actionPinchGesture(recognize: sender, in: self.canvasView)
    }
    
    @IBAction func capturedImagePinchAction(_ sender: UIPinchGestureRecognizer) {
//        self.capturedImageView.actionPinchGesture(recognize: sender, in: self.canvasView)
    }
    
    
    @IBAction func filteredImagePanAction(_ sender: UIPanGestureRecognizer) {
//        self.filteredImageView.actionPanGesture(recognize: sender, in: self.canvasView)
    }
    
    @IBAction func capturedImagePanAction(_ sender: UIPanGestureRecognizer) {
//        self.capturedImageView.actionPanGesture(recognize: sender, in: self.canvasView)
    }
    
    @IBAction func adjustScreenPopup(_ sender: UIButton) {
        self.view.addGestureRecognizer(modalBackgroundTapGestureRecognizer)
        present(coordinator.modalView, animated: true, completion: nil)
    }
    
    @IBAction func modalBackgroundTapAction(_ sender: UITapGestureRecognizer) {
        self.view.removeGestureRecognizer(modalBackgroundTapGestureRecognizer)
        self.coordinator.modalView.dismissAction()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.removeGestureRecognizer(modalBackgroundTapGestureRecognizer)
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController) -> UIPresentationController? {
        
        let modalCanvasViewRect = CGRect(
            origin: CGPoint(x: 0, y: self.canvasView.frame.maxY),
            size: self.adjustRootStackView.frame.size)
        
        return FilterPresentationViewController(modalCanvasViewRect: modalCanvasViewRect,
                          coordinator: coordinator,
                          presentedViewController: presented,
                          presenting: presenting)
    }
}

class FilterPresentationViewController: UIPresentationController {
    var modalCanvasViewRect: CGRect
    let coordinator: FilterViewCoordinator
    
    required init(modalCanvasViewRect: CGRect,
                  coordinator: FilterViewCoordinator,
                  presentedViewController: UIViewController,
                  presenting: UIViewController?) {
        
        self.modalCanvasViewRect = modalCanvasViewRect
        self.coordinator = coordinator
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            return CGRect(
                origin: CGPoint(x: 0, y: modalCanvasViewRect.origin.y),
                size: modalCanvasViewRect.size)
        }
    }
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        presentedView?.layer.cornerRadius = 12
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        self.presentingViewController.setNeedsFocusUpdate()
    }
    
}

//MARK: - Filtering methods
extension FilterViewController {
    func registerPhoto() {
        
        guard let imageManager = self.imageManager, let asset = self.currentAsset else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        imageManager.requestImage(
            for: asset,
            targetSize: .zero,
            contentMode: .aspectFill,
            options: nil) { [self] (image, _) in
            
            if let image = image {
                
                initialCIImage = CIImage(image: image)
                initialImage = image
                
                initiateBasicFilter()
            }
        }
    }
    
    private func initiateBasicFilter() {
        
        basicFilter = BasicFilterTemplate(image: initialCIImage)
        basicFilter.filterName = filters[0]
        basicFilter.delegate = self
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
    
    
    func adjustValue(sender: UISlider, _ key: FilterAdjustKey ) {
        
        basicFilter.adjustKey = key
        basicFilter.adjustValue = sender.value
//        basicFilter.wouldDelegateExecute = true
        basicFilter.admitFilter(to: initialCIImage, filtername: basicFilter.adjustKey.rawValue)
        
        DispatchQueue.main.async { [self] in
            
//            if let filteredImage = self.filteredImage {
//                self.basicFilter.needToAdjustCIImage = CIImage(image: filteredImage) ?? self.initialCIImage
//            } else {
//                self.basicFilter.needToAdjustCIImage = self.initialCIImage
//            }
        }
    }
}

//MARK: - UICollectionView Methods
extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let targetImage = self.initialCIImage else {
            return
        }
        
        basicFilter.admitFilter(to: targetImage, filtername: filters[indexPath.row], isAdjust: false)
        
        basicFilter.filterName = filters[indexPath.row]
        basicFilter.needToFilterCIImage = initialCIImage
        
        DispatchQueue.main.async { [self] in
            
            filteredImageView.image = filteredImage ?? initialImage
            collectionView.cellForItem(at: indexPath)?.alpha = 0.5
        }
        
        coordinator.modalView.adjustValueToZero()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.alpha = 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterItems", for: indexPath)
        
        guard let initialImage = self.initialCIImage else {
            return cell
        }
        
        basicFilter.wouldDelegateExecute = false
        basicFilter.admitFilter(to: initialImage, filtername: filters[indexPath.row], isAdjust: false)
        
        cell.backgroundView = UIImageView(image: UIImage(ciImage: basicFilter.filteredImage))
        
        return cell
    }
}

extension FilterViewController: BasicFilterTemplageDelegate {
    func afterFilterChanged(as image: CIImage, for filterKey: String) {
        
        guard let filteredCGImage = basicFilter.filterContext.createCGImage(image, from: image.extent) else {
            return
        }
        
        let processedImage = UIImage(cgImage: filteredCGImage)
        filteredImageView.image = processedImage
        filteredImage = processedImage
    }
    
    func afterAdjustingValueChange(as image: CIImage, using adjustKey: FilterAdjustKey, for adjustVal: Float) {
        
        guard let filteredCGImage = basicFilter.filterContext.createCGImage(image, from: image.extent) else {
            return
        }
        
        let processedImage = UIImage(cgImage: filteredCGImage)
        filteredImageView.image = processedImage
        filteredImage = processedImage
    }
}

extension FilterViewController: UITextFieldDelegate {
    //return 키 누르면 텍스트 닫힘.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = ((sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 150) * -1 // Move view upward
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
}
