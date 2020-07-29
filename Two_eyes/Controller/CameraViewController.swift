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
import ChameleonFramework

class CameraViewController: UIViewController, PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
    }

    @IBOutlet var cameraPreview: UIView!
    @IBOutlet var currentPicture: UIButton!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    var currentPictureRequested: Bool = false
    var capturedImage: UIImage?
    var currentAsset: PHAsset?
    var currentAssetFetchOptions: PHFetchOptions?
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var currentCameraInput: AVCaptureInput?
    fileprivate var currentCameraType: AVCaptureDevice.DeviceType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: CGRect(origin: view.frame.origin, size: view.frame.size), andColors: [UIColor.flatSand(), UIColor.flatSandDark()])
        
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
        
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = cameraPreview.layer.bounds
        cameraPreview.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.startRunning()
        
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true
        captureSession?.addOutput(capturePhotoOutput!)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        registerNewPhoto()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func registerNewPhoto() {
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
            if let destinationVC = self.storyboard?.instantiateViewController(identifier: Constants.filterViewControllerIdentifier) as? FilterViewController{
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
    
    func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        
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
