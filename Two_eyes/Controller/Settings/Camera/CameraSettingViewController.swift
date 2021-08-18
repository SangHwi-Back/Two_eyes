//
//  CameraSettingViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/07/29.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit

class CameraSettingViewController: UICollectionViewController, SettingInterfaceBasicProtocol, UICollectionViewDelegateFlowLayout {
    internal var settingName: String = ""
    private var cellReuseIdentifier: String? {
        get{
            Constants.settingsCellReuseIdentifier[settingName]
        }
    }
    private var cellTitles: [String] {
        get{
            Constants.cameraSettingTypes
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        padding = view.frame.width / 10
        if let cellReuseIdentifier = cellReuseIdentifier {
            self.collectionView!.register(
                UINib(nibName: "CameraSettingViewCell", bundle: nil),
                forCellWithReuseIdentifier: cellReuseIdentifier)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationItem.title = nil
        navigationItem.hidesBackButton = true
    }
    
    @objc func movePrev() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellTitles.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier ?? "", for: indexPath) as? CameraCollectionViewCell else {
            fatalError()
        }
    
        cell.largeContentTitle = cellTitles[indexPath.row]
        cell.cameraSettingLabel.text = cellTitles[indexPath.row]
        
        return cell
    }

    //MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    private var padding: CGFloat = 0.0
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 2 - padding, height: view.frame.width / 2 - padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding/2, left: padding/1.5, bottom: padding, right: padding/1.5)
    }
    
}
