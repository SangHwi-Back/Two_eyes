//
//  CameraViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/11.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import PhotosUI

class CameraViewController: UIViewController, PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {}

    @IBOutlet var cameraPreview: UIView!
    @IBOutlet var currentPicture: UIButton!
    
    private var captureSession: AVCaptureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var capturePhotoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    
    var currentPictureRequested: Bool = false
    private var capturedImage: UIImage?
    private var currentAsset: PHAsset?
    private var currentAssetFetchOptions: PHFetchOptions?
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate let photoSettings = AVCapturePhotoSettings()
    fileprivate var currentCameraInput: AVCaptureInput?
    fileprivate var currentCameraType: AVCaptureDevice.DeviceType?
    private weak var destinationVC: FilterViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentPictureRequested { return }
        
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            currentCameraType = captureDevice.deviceType
            if let input = try? AVCaptureDeviceInput(device: captureDevice), captureSession.canAddInput(input) {
                currentCameraInput = input
                captureSession.addInput(input)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            } else {
                if let viewControllers = self.tabBarController?.viewControllers {
                    for vc in viewControllers {
                        if let vc = vc as? SearchAndLoadViewController {
                            self.tabBarController?.selectedViewController = vc
                        }
                    }
                }
                self.tabBarController?.reloadInputViews()
            }
        }
        
        guard let videoPreviewLayer = videoPreviewLayer else { return }
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = cameraPreview.layer.bounds
        cameraPreview.layer.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
        
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        captureSession.addOutput(capturePhotoOutput)
        photoSettings.flashMode = .auto
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setTheme()
        
        registerNewPhoto()
    }
    
    private func registerNewPhoto() {
        let photoOptions = PHFetchOptions()
        photoOptions.fetchLimit = 1
        photoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        currentAssetFetchOptions = photoOptions
        
        let newPhoto = PHAsset.fetchAssets(with: photoOptions)
        
        if let currentAsset = newPhoto.firstObject {
            imageManager.requestImage(
                    for: currentAsset,
                    targetSize: currentPicture.frame.size,
                    contentMode: .aspectFill,
                    options: nil) { (image, _) in
                self.currentAsset = currentAsset
                self.currentPicture.setBackgroundImage(image, for: .normal)
                self.currentPictureRequested = true
            }
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        self.captureSession.stopRunning()
    }
    
    //MARK: - Buttons action methods
    @IBAction func currentPhoto(_ sender: UIButton) {
        if let destinationVC = self.storyboard?.instantiateViewController(identifier: "FilterMainViewController") as? FilterMainViewController {
//            self.destinationVC = self.storyboard?.instantiateViewController(identifier: Constants.filterViewControllerIdentifier) as? FilterViewController
            destinationVC.currentAsset = self.currentAsset
            destinationVC.imageManager = self.imageManager
            if currentPictureRequested {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    @IBAction func takePhoto(_ sender: UIButton) {
        capturePhotoOutput.capturePhoto(with: AVCapturePhotoSettings(from: self.photoSettings), delegate: self)
    }
    @IBAction func reverseCamera(_ sender: UIButton) {
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        let nextPosition = ((currentCameraInput as? AVCaptureDeviceInput)?.device.position == .front) ? AVCaptureDevice.Position.back : .front
        
        if let currentCameraInput = currentCameraInput {
            captureSession.removeInput(currentCameraInput)
        }

        if let newCamera = cameraDevice(position: nextPosition),
            let newVideoInput = try? AVCaptureDeviceInput(device: newCamera) {
            captureSession.canAddInput(newVideoInput)
            captureSession.addInput(newVideoInput)
            currentCameraInput = newVideoInput
        }
    }
    
    private func cameraDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if let currentCameraType = currentCameraType {
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [currentCameraType], mediaType: .video, position: .unspecified)
            for device in discoverySession.devices where device.position == position {
                return device
            }
        }
        return nil
    }
    
    private func resetCachedAssets() {
        self.imageManager.stopCachingImagesForAllAssets()
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let imageData = photo.fileDataRepresentation() else { return }
        
        registerNewPhoto()
        
        if let capturedImage = UIImage(data: imageData, scale: 1.0) {
            UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil)
            if let destinationVC = self.storyboard?.instantiateViewController(identifier: "FilterMainViewController") as? FilterMainViewController {
                
                destinationVC.initialImage = capturedImage
                destinationVC.currentAsset = currentAsset
                destinationVC.imageManager = imageManager
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
}

extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject, metadataObj.type == AVMetadataObject.ObjectType.qr, metadataObj.stringValue != nil {
            debugPrint(metadataObj.stringValue!)
        }
    }
}
