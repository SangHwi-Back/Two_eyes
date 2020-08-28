//
//  SearchAndLoadViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/11.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//  Reference1 ::: https://www.raywenderlich.com/9334-uicollectionview-tutorial-getting-started
//  Reference2 ::: https://developer.apple.com/documentation/photokit/browsing_and_modifying_photo_albums
//  Reference3 ::: https://developer.apple.com/documentation/vision/locating_and_displaying_recognized_text_on_a_document
//

import UIKit
import Photos
import PhotosUI
import CoreML
import Vision

class SearchAndLoadViewController: UIViewController {

    //MARK: - Outlet, var, let declaration
    @IBOutlet var albumSearchBar: UISearchBar!
    @IBOutlet var albumCollectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet var cancelButton: UIButton!
    
    // MARK: Properties
    private var allPhotos: PHFetchResult<PHAsset>!
    private var smartAlbums: PHFetchResult<PHAssetCollection>!
    private var photosCollection: PHAssetCollection!
    private var userCollections: PHFetchResult<PHCollection>!
    
    var availableWidth: CGFloat = 0
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    fileprivate let textRecognitionRequest = VNRecognizeTextRequest()
    
    private let cellImageOptions = PHImageRequestOptions()
    
    private let themeManager = (UIApplication.shared.delegate as! AppDelegate).themeManager!
    
    //MARK: - Method related view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = true
        
        albumSearchBar.delegate = self
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.masksToBounds = true
        
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        
        textRecognitionRequest.recognitionLevel = .fast
        textRecognitionRequest.revision = VNRecognizeTextRequestRevision1
        textRecognitionRequest.usesLanguageCorrection = false
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    @IBAction func cancelButtonInAction(_ sender: UIButton) {
        self.albumSearchBar.resignFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionViewFlowLayout.itemSize = thumbnailSize
    }
    
    /**
     뷰가 나타나기 전 이미지 썸네일 크기를 설정한다. ( ViewWillLayoutSubView 보다 먼저 호출 )
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        thumbnailSize = CGSize(
            width: self.view.frame.width / 3 - 20,
            height: (self.view.frame.width / 3 - 20) * 1.2)
        
        cellImageOptions.normalizedCropRect.size = thumbnailSize
        cellImageOptions.resizeMode = .exact
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions) //Photo Library load
        
        albumCollectionView.reloadData()
        
        self.navigationController?.navigationBar.isTranslucent = (themeManager.getNavtabBackgroundColor() == UIColor.systemBackground ? true : false)
        self.navigationController?.navigationBar.barTintColor = themeManager.getNavtabBackgroundColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: themeManager.getBodyTextColor()]
        self.tabBarController?.tabBar.barTintColor = themeManager.getNavtabBackgroundColor()
        self.view.backgroundColor = themeManager.getThemeBackgroundColor()
        self.albumSearchBar.alpha = 0.5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? SearchAndLoadDetailViewController else {
            fatalError("fatalError occured at destinationVC segue")
        }
        guard let cell = sender as? UICollectionViewCell else {
            fatalError("fatalError occured at collectionViewCell segue")
        }
        let indexPath = albumCollectionView.indexPath(for: cell)!
        destination.asset = allPhotos.object(at: indexPath.item)
        destination.imageManager = self.imageManager
        destination.assetCollection = photosCollection
    }
    
    //MARK: - Load album images with cache
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //func for load image quickly
        updateCachedAssets()
    }
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
    
    /**
     Photo Library의 사진(사용하는 아이폰의 사진)을 PHCachingImageManager를 이용하여 업데이트 한다.
     */
    fileprivate func updateCachedAssets() {
        guard isViewLoaded, view.window != nil else {
            return
        }
        
        //미리 두 배의 윈도우 높이 값을 가져옴.
        let visibleRect = CGRect(origin: albumCollectionView!.contentOffset, size: albumCollectionView!.frame.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -1 * visibleRect.height)
        
        //preheatRect보다 현재 보는 화면이 현저히 차이가 날 경우만 업데이트.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > (view.bounds.height / 3) else {
            return
        }
        
        //자료화면(앨범 이미지들)을 불러온다. 새로 추가될 이미지는 addedAssets, 지울 이미지는 removedAssets
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap {rect in albumCollectionView!.indexPathsForElement(in: rect)}
            .map {indexPath in allPhotos.object(at: indexPath.item)}
        let removedAssets = removedRects
            .flatMap {rect in albumCollectionView!.indexPathsForElement(in: rect)}
            .map {indexPath in allPhotos.object(at: indexPath.item)}
        
        //PHImageManager의 Cache를 조정한다. 지워질 Assets에 대해서는 Cache를 없애고, 추가될 Assets에 대해서는 반대로 한다.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: cellImageOptions)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: cellImageOptions)
        
        previousPreheatRect = preheatRect
    }
    
    //MARK: - Utility Methods
    /**
    두 개의 CGRect을 겹쳤을 때 각각의 파라미터 측면에서 추가되고 제외된 부분을 각각 반환한다.
     */
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }

}

extension SearchAndLoadViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
}

extension SearchAndLoadViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.searchCellReuseIdentifier, for: indexPath) as? SearchAndLoadCollectionViewCell else {
            fatalError("Unexpected cell in collection view2")
        }
        
        //Live Photo Thunbnail 추가
        let asset = allPhotos.object(at: indexPath.item)
        if asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
        
        cell.frame.size = thumbnailSize
        
        //cell에 넣을 미리 로딩된 이미지를 불러온다.
        cell.representAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset,
                                  targetSize: thumbnailSize,
                                  contentMode: .aspectFill,
                                  options: cellImageOptions) { (image, _) in
            if cell.representAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        }
        
        return cell
    }
    
}

extension SearchAndLoadViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateCachedAssets()
        albumCollectionView.reloadData()
    }

    //이미지 불러오기 시작, ML작업 시작
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        resetCachedAssets()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        allPhotos.enumerateObjects { (asset, inx, isStop) in
            asset.requestContentEditingInput(with: nil) { (input, info) in
                if let url = input?.fullSizeImageURL {
                    let instRequestHandler = VNImageRequestHandler(url: url, options: [:])
                    try? instRequestHandler.perform([self.textRecognitionRequest]) // 오류가 났어!!
                    
                    guard let visionResult = self.textRecognitionRequest.results as? [VNRecognizedTextObservation] else {
                        return
                    }
                    
                    for result in visionResult {
                        guard let candidate = result.topCandidates(1).first else {
                            continue
                        }
                        if let searchText = searchBar.searchTextField.text,
                            candidate.string.range(of: searchText)?.isEmpty ?? false {
                        }
                    }
                }
            }
        }
    }
    
    //이미지 불러오기 종료, ML작업 종료
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { }
}

extension SearchAndLoadViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("PHPhotoLibraryChangeObserver")
    }
    
    
}

private extension UICollectionView {
    // layoutAttributes를 반영한 CollectionView의 아이템을 반환한다.
    func indexPathsForElement(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map {$0.indexPath}
    }
}
