//
//  SearchAndLoadDetailViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/12.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//  Reference ::: https://developer.apple.com/documentation/photokit/browsing_and_modifying_photo_albums
//

import UIKit
import Photos
import PhotosUI

class SearchAndLoadDetailViewController: UIViewController {
    
    var asset: PHAsset! // Photo Library
    var assetCollection: PHAssetCollection! // Photo Library's detail data.
    var imageManager: PHCachingImageManager?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet var playButton: UIBarButtonItem!
    @IBOutlet var space: UIBarButtonItem!
    @IBOutlet var trashButton: UIBarButtonItem!
    @IBOutlet var favoriteButton: UIBarButtonItem!
    
    fileprivate var playerLayer: AVPlayerLayer!
    fileprivate var isPlayingHint = false
    fileprivate lazy var formatIdentifier = Bundle.main.bundleIdentifier!
    fileprivate lazy var ciContext = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        livePhotoView.delegate = self
        PHPhotoLibrary.shared().register(self)
        navigationItem.hidesBackButton = false
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        navigationController?.isToolbarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        
        if asset.mediaType == .video {
            toolbarItems = [favoriteButton, space, playButton, space, trashButton]
        } else {
            toolbarItems = [favoriteButton, space, trashButton]
        }
        
        //불러온 Asset들의 메타 데이터를 변경할 수 있음을 선언한다.
        favoriteButton.isEnabled = asset.canPerform(.properties)
        favoriteButton.title = asset.isFavorite ? "♥︎" : "♡"
        
        //삭제 버튼 구현
        if assetCollection != nil {
            trashButton.isEnabled = assetCollection.canPerform(.removeContent)
        } else {
            trashButton.isEnabled = asset.canPerform(.delete)
        }
        
        //viewLayout이 이미지를 화면에 맞추기 전에 불러올 수 있도록 한다.
        view.layoutIfNeeded()
        updateImage()
    }
}

extension SearchAndLoadDetailViewController {
    private func updateImage() {
        if asset.mediaSubtypes.contains(.photoLive) {
            updateLivePhoto()
        } else {
            updateStaticImage()
        }
    }
    
    private var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale, height: imageView.bounds.height * scale)
    }
    
    //Live Photo 이미지를 뷰에 세팅함.
    private func updateLivePhoto() {
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            DispatchQueue.main.async {
                self.progressView.progress = Float(progress)
            }
        }
        
        PHImageManager.default().requestLivePhoto(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (livePhoto, info) in
            guard let livePhoto = livePhoto else { return }
            
            self.progressView.isHidden = true
            self.imageView.isHidden = true
            self.livePhotoView.isHidden = false
            self.livePhotoView.livePhoto = livePhoto
            
            if !self.isPlayingHint {
                self.isPlayingHint = true
                self.livePhotoView.startPlayback(with: .hint)
            }
        }
    }
    
    //정적 이미지를 뷰에 세팅함.
    private func updateStaticImage() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            DispatchQueue.main.async {
                self.progressView.progress = Float(progress)
            }
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, _) in
            guard let image = image else { return }
            
            self.progressView.isHidden = true
            self.livePhotoView.isHidden = true
            self.imageView.isHidden = false
            self.imageView.image = image
        }
    }
    
    @IBAction func usePhotoClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "usePhotoSegue", sender: self)
    }
    
    //trash 버튼 클릭. asset에서 하나 제거 하면서 현재의 화면은 popViewController로 없애버림.
    @IBAction func removeAsset(_ sender: UIBarButtonItem) {
        let completionHandler = { (success: Bool, error: Error?) -> Void in
            if success {
                PHPhotoLibrary.shared().unregisterChangeObserver(self)
                DispatchQueue.main.async {
                    self.navigationController!.popViewController(animated: true)
                }
            } else {
                print("Can't remove the asset")
            }
        }
        if assetCollection != nil {
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCollectionChangeRequest(for: self.assetCollection)!
                request.removeAssets([self.asset as Any] as NSArray)
            }, completionHandler: completionHandler)
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([self.asset as Any] as NSArray)
            }, completionHandler: completionHandler)
        }
    }
    
    @IBAction func favoriteClicked(_ sender: UIBarButtonItem) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest(for: self.asset)
            request.isFavorite = self.asset.isFavorite
        }) { (success, error) in
            if success {
                DispatchQueue.main.sync {
                    sender.title = self.asset.isFavorite ? "♥︎" : "♡"
                }
            } else {
                print("Can't remove the asset")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "usePhotoSegue", let destinationVC = segue.destination as? FilterViewController {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.progressHandler = { progress, _, _, _ in
                DispatchQueue.main.async {
                    self.progressView.progress = Float(progress)
                }
            }
            
            destinationVC.currentAsset = asset
            destinationVC.imageManager = self.imageManager
        }
    }
    
    //play 버튼 클릭. PHImageManager의 플레이어를 가져옴.
    @IBAction func play(_ sender: Any) {
        if playerLayer != nil {
            playerLayer.player?.play()
        } else {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic
            options.progressHandler = { progress, _, _, _ in
                DispatchQueue.main.async {
                    self.progressView.progress = Float(progress)
                }
            }
            
            PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { (playerItem, info) in
                DispatchQueue.main.async {
                    guard self.playerLayer == nil else { return }
                    
                    let player = AVPlayer(playerItem: playerItem)
                    let playerLayer = AVPlayerLayer(player: player)
                    
                    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                    playerLayer.frame = self.view.layer.bounds
                    self.view.layer.addSublayer(playerLayer)
                    
                    player.play()
                    self.playerLayer = playerLayer
                }
            }
        }
    }
}

extension SearchAndLoadDetailViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) { }
}

extension SearchAndLoadDetailViewController: PHLivePhotoViewDelegate {
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) { }
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) { }
}
