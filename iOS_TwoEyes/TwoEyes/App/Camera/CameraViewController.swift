//
//  CameraViewController.swift
//  PhotoApp
//
//  Created by SangHwiBack on 3/3/26.
//

import UIKit
import AVFoundation
import PhotosUI
import Combine

class CameraViewController: UIViewController {
    
    private var images = [UIImage]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<CameraViewModel.Section, CameraViewModel.Item>?
    
    private let viewModel = CameraViewModel()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(
            UINib(nibName: String(describing: CameraViewHeaderCell.self), bundle: nil),
            forCellWithReuseIdentifier: String(describing: CameraViewHeaderCell.self))
        collectionView.register(
            UINib(nibName: String(describing: CameraViewSelectedImagesCell.self), bundle: nil),
            forCellWithReuseIdentifier: String(describing: CameraViewSelectedImagesCell.self))
        collectionView.register(
            UINib(nibName: String(describing: CameraViewImageCollectionViewCell.self), bundle: nil),
            forCellWithReuseIdentifier: String(describing: CameraViewImageCollectionViewCell.self))
        collectionView.register(
            UINib(nibName: String(describing: CameraViewButtonsCell.self), bundle: nil),
            forCellWithReuseIdentifier: String(describing: CameraViewButtonsCell.self))
        collectionView.register(
            UINib(nibName: String(describing: CameraViewTraitScrollCell.self), bundle: nil),
            forCellWithReuseIdentifier: String(describing: CameraViewTraitScrollCell.self))
        
        viewModel.output.sink { [weak self] effect in
            switch effect {
            case .openAlbum:
                self?.albumButtonTouchUpInside()
            case .openCamera:
                self?.cameraButtonTouchUpInside()
            case .openSetting:
                self?.showAlertGoToSetting()
            case .cancel:
                self?.dismiss(animated: true)
            case .reloadPhotos:
                print("")
            }
        }.store(in: &cancellables)
        
        registerForTraitChanges([UITraitVerticalSizeClass.self, UITraitHorizontalSizeClass.self]) { [weak self] (
            traitEnvironment: CameraViewController,
            previousTraitCollection: UITraitCollection
        ) in
            let trait = traitEnvironment.traitCollection
            self?.reload(trait)
        }
        
        reload(traitCollection)
    }
    
    private func reload(_ traitCollection: UITraitCollection) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            // 세팅값 가져오기
            let settings = self.viewModel.getCollectionViewSetting(
                with: traitCollection)
            // 레이아웃 세팅
            self.collectionView.collectionViewLayout = settings.layout
            // 데이터소스 세팅
            self.dataSource = .init(
                collectionView: self.collectionView,
                cellProvider: settings.dataSource)
            self.collectionView.dataSource = self.dataSource
            // 스냅샷 세팅
            self.dataSource?.apply(settings.snapshot)
        }
    }
    
    private func showAlertGoToSetting() {
        let alert = UIAlertController(
            title: "현재 카메라 사용에 대한 접근 권한이 없습니다.",
            message: "설정 > PhotoApp 에서 접근을 활성화 할 수 있습니다.",
            preferredStyle: .alert
        )
        
        let actions = [
            UIAlertAction(title: "취소", style: .cancel) { _ in
                alert.dismiss(animated: true, completion: nil)
            },
            UIAlertAction(title: "설정으로 이동하기", style: .default) { _ in
                guard
                    let settingURL = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(settingURL)
                else {
                    return
                }
                
                UIApplication.shared.open(settingURL, options: [:])
            }
        ]
        
        actions.forEach(alert.addAction(_:))
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
    
    private func cameraButtonTouchUpInside() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
            if isAuthorized {
                DispatchQueue.main.async { [weak self] in
                    let picker = UIImagePickerController()
                    picker.sourceType = .camera
                    picker.allowsEditing = false
                    picker.mediaTypes = ["public.image"]
                    picker.delegate = self?.viewModel
                    self?.present(picker, animated: true)
                }
            } else {
                self?.showAlertGoToSetting()
            }
        }
    }
    
    private func albumButtonTouchUpInside() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
            if isAuthorized {
                DispatchQueue.main.async { [weak self] in
                    var conf = PHPickerConfiguration()
                    conf.filter = .all(of: [.images, .livePhotos])
                    let picker = PHPickerViewController(configuration: conf)
                    picker.delegate = self?.viewModel
                    self?.present(picker, animated: true)
                }
            } else {
                self?.showAlertGoToSetting()
            }
        }
    }
}
