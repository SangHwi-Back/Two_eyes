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
    var capturedViewLabel = UILabel()
    var filteredViewLabel = UILabel()
    
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
    var initialImage: UIImage?
    
    private let themeManager = (UIApplication.shared.delegate as! AppDelegate).themeManager!
    
    //MARK: - Methods executed in view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        
        self.filterItemsCollectionView.delegate = self
        self.filterItemsCollectionView.dataSource = self
        self.filterItemsCollectionView.allowsSelection = true
        
        registerPhoto()
        self.basicFilter.delegate = self
        coordinatorSetting()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        filteredViewLabel.text = "필터이미지"
        filteredViewLabel.textColor = .white
        capturedViewLabel.text = "원본"
        capturedViewLabel.textColor = .white
        
        // Gesture source Start
        self.filteredImageView.isUserInteractionEnabled = true
        self.capturedImageView.isUserInteractionEnabled = true
        
        self.filteredImageView.addSubview(filteredViewLabel)
        self.capturedImageView.addSubview(capturedViewLabel)
        
        filteredViewLabel.bounds = filteredImageView.frame
        capturedViewLabel.bounds = capturedImageView.frame
        
        self.capturedImageView.layer.zPosition = 1
        self.filteredImageView.layer.zPosition = 2
        self.canvasView.layer.zPosition = 0
        self.adjustRootStackView.layer.zPosition = 3
        // Gesture source End
        
        basicFilter.wouldDelegateExecute = true
        basicFilter.filterName = filters[0]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = (themeManager.getNavtabBackgroundColor() == UIColor.systemBackground ? true : false)
        self.navigationController?.navigationBar.barTintColor = themeManager.getNavtabBackgroundColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: themeManager.getBodyTextColor()]
        self.tabBarController?.tabBar.barTintColor = themeManager.getNavtabBackgroundColor()
        self.view.backgroundColor = themeManager.getThemeBackgroundColor()
    }
    
    deinit {
        navigationController?.navigationBar.isHidden = true
    }
    
    func coordinatorSetting() {
        //modalMasterView
        coordinator.modalMasterView = self
        
        //modal(Detail)View
        coordinator.modalView = AdjustModalViewController(coordinator: coordinator)
        coordinator.modalView?.modalPresentationStyle = .custom
        coordinator.modalView?.isModalInPresentation = true
        coordinator.modalView?.transitioningDelegate = self
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
    }
    
    @IBAction func filteredImagePinchAction(_ sender: UIPinchGestureRecognizer) {
        self.filteredImageView.actionPinchGesture(recognize: sender, in: self.canvasView)
    }
    
    @IBAction func capturedImagePinchAction(_ sender: UIPinchGestureRecognizer) {
        self.capturedImageView.actionPinchGesture(recognize: sender, in: self.canvasView)
    }
    
    
    @IBAction func filteredImagePanAction(_ sender: UIPanGestureRecognizer) {
        self.filteredImageView.actionPanGesture(recognize: sender, in: self.canvasView)
    }
    
    @IBAction func capturedImagePanAction(_ sender: UIPanGestureRecognizer) {
        self.capturedImageView.actionPanGesture(recognize: sender, in: self.canvasView)
    }
    
    @IBAction func adjustScreenPopup(_ sender: UIButton) {
        self.view.addGestureRecognizer(modalBackgroundTapGestureRecognizer)
        if let customModalView = coordinator.modalView {
            present(customModalView, animated: true, completion: nil)
        }
    }
    
    @IBAction func modalBackgroundTapAction(_ sender: UITapGestureRecognizer) {
        self.view.removeGestureRecognizer(modalBackgroundTapGestureRecognizer)
        self.coordinator.modalView?.dismissAction()
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
        
        return CustomView(modalCanvasViewRect: modalCanvasViewRect,
                          coordinator: coordinator,
                          presentedViewController: presented,
                          presenting: presenting)
    }
}

class CustomView: UIPresentationController {
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
        var tempImage: UIImage?
        
        if initialImage != nil {
            tempImage = initialImage!
        }
        
        if let imageManager = self.imageManager, let currentAsset = self.currentAsset {
            imageManager.requestImage(for: currentAsset,
                                      targetSize: capturedImageView.frame.size,
                                      contentMode: .aspectFit,
                                      options: nil) { (image, _) in
                tempImage = image
            }
        }
        
        if let safeImage = tempImage {
            capturedImageView.image = safeImage
            filteredImageView.image = safeImage
            self.basicFilter = BasicFilterTemplate(image: safeImage)
            self.basicFilter.filterName = filters[0]
            self.initialImage = safeImage
        } else {
            self.navigationController?.popViewController(animated: true)
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
    
    
    func adjustValue(sender: UISlider, _ key: String) {
        let center = self.filteredImageView.center
        basicFilter.adjustKey = key
        basicFilter.adjustValue = sender.value
        DispatchQueue.main.async {
            self.basicFilter.preAdjustedImage = self.initialImage!
            self.filteredImageView.image = self.basicFilter.filteredImage
            self.filteredImageView.center = center
        }
    }
}

//MARK: - UICollectionView Methods
extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        basicFilter.filterName = filters[indexPath.row]
        
        filteredImageView.image = basicFilter.filteredImage
        filterItemsCollectionView.cellForItem(at: indexPath)?.alpha = 0.5
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
        cell.backgroundView = UIImageView(image: basicFilter.filteredImage)
        return cell
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
        self.view.frame.origin.y = ((sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 150) * -1 // Move view upward
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
        // view가 가로로 반 이상 잘리면 더 이상 이동 불가
        if view.center.x + translation.x <= 0 { // 왼쪽
            return view.center.x
        } else if view.center.x + translation.x >= canvas.frame.width { // 오른쪽
            return view.center.x
        } else {
            return view.center.x + translation.x
        }
    }
    
    func getChangedY(from view: UIImageView, as translation: CGPoint, canvas: UIView) -> CGFloat {
        // view가 세로로 반 이상 잘리면 더 이상 이동 불가
        if view.center.y + translation.y <= 0 { // 위
            return view.center.y
        } else if view.center.y + translation.y >= canvas.frame.height { // 아래
            return view.center.y
        } else {
            return view.center.y + translation.y
        }
    }
    
}
