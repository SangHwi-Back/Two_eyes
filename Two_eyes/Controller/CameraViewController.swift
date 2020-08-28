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
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var capturePhotoOutput: AVCapturePhotoOutput?
    
    private var currentPictureRequested: Bool = false
    private var capturedImage: UIImage?
    private var currentAsset: PHAsset?
    private var currentAssetFetchOptions: PHFetchOptions?
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var currentCameraInput: AVCaptureInput?
    fileprivate var currentCameraType: AVCaptureDevice.DeviceType?
    private let themeManager = (UIApplication.shared.delegate as! AppDelegate).themeManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            currentCameraType = captureDevice.deviceType
            if let input = try? AVCaptureDeviceInput(device: captureDevice) {
                captureSession = AVCaptureSession()
                currentCameraInput = input
                captureSession?.addInput(input)
            }
        }
        
        if let captureSession = captureSession {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        } else {
            performSegue(withIdentifier: "filterViewSearchSegue", sender: self)
            return
        }
        
        capturePhotoOutput = AVCapturePhotoOutput()
        
        guard let videoPreviewLayer = videoPreviewLayer, let captureSession = captureSession, let capturePhotoOutput = capturePhotoOutput else { return }
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = cameraPreview.layer.bounds
        cameraPreview.layer.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
        
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        captureSession.addOutput(capturePhotoOutput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = (themeManager.getNavtabBackgroundColor() == UIColor.systemBackground ? true : false)
        self.navigationController?.navigationBar.barTintColor = themeManager.getNavtabBackgroundColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: themeManager.getBodyTextColor()]
        self.tabBarController?.tabBar.barTintColor = themeManager.getNavtabBackgroundColor()
        self.view.backgroundColor = themeManager.getThemeBackgroundColor()
        
        registerNewPhoto()
    }
    
    private func registerNewPhoto() {
        let photoOptions = PHFetchOptions()
        photoOptions.fetchLimit = 1
        photoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        currentAssetFetchOptions = photoOptions
        
        let newPhoto = PHAsset.fetchAssets(with: photoOptions)
        currentAsset = newPhoto.object(at: 0)
                
        imageManager.requestImage(for: currentAsset!, targetSize: currentPicture.frame.size, contentMode: .aspectFit, options: nil) { (image, _) in
            self.currentPicture.setBackgroundImage(image, for: .normal)
            self.currentPictureRequested = true
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        self.captureSession?.stopRunning()
    }
    
    @IBAction func currentPhoto(_ sender: UIButton) {
        if currentPictureRequested {
            if let destinationVC = self.storyboard?.instantiateViewController(identifier: Constants.filterViewControllerIdentifier) as? FilterViewController {
                destinationVC.currentAsset = self.currentAsset
                destinationVC.imageManager = self.imageManager
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    @IBAction func takePhoto(_ sender: UIButton) {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true // 저장된 갚으로 대체할 것
        photoSettings.flashMode = .auto
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @IBAction func reverseCamera(_ sender: UIButton) {
        captureSession?.beginConfiguration()
        defer { captureSession?.commitConfiguration() }
        
        let nextPosition = ((currentCameraInput as? AVCaptureDeviceInput)?.device.position == .front) ? AVCaptureDevice.Position.back : .front
        
        if let currentCameraInput = currentCameraInput {
            captureSession?.removeInput(currentCameraInput)
        }

        if let newCamera = cameraDevice(position: nextPosition),
            let newVideoInput = try? AVCaptureDeviceInput(device: newCamera) {
            captureSession?.canAddInput(newVideoInput)
            captureSession?.addInput(newVideoInput)
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
        
        if let capturedImage = UIImage.init(data: imageData, scale: 1.0) {
            UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil)
            if let destinationVC = self.storyboard?.instantiateViewController(identifier: Constants.filterViewControllerIdentifier) as? FilterViewController {
                destinationVC.initialImage = capturedImage
                destinationVC.imageManager = self.imageManager
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
}

extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr, metadataObj.stringValue != nil {
            debugPrint(metadataObj.stringValue!)
        }
    }
}
