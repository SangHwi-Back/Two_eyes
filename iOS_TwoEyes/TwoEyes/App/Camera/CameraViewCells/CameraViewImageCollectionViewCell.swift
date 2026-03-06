//
//  CameraViewImageCollectionViewCell.swift
//  PhotoApp
//
//  Created by SangHwiBack on 3/6/26.
//

import UIKit

class CameraViewImageCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    private var images = [UIImage]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(
            UINib(nibName: String(describing: CameraCollectionViewImageCell.self), bundle: nil),
            forCellWithReuseIdentifier: String(describing: CameraCollectionViewImageCell.self))
        collectionView.register(
            UINib(nibName: String(describing: CameraCollectionViewEmptyCell.self), bundle: nil),
            forCellWithReuseIdentifier: String(describing: CameraCollectionViewEmptyCell.self))
    }
    
    func updateImages(_ images: [UIImage]) {
        self.images = images
        self.collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count == 0 ? 1 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard images.isEmpty == false else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CameraCollectionViewEmptyCell.self), for: indexPath)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CameraCollectionViewImageCell.self), for: indexPath)
        
        if let cell = cell as? CameraCollectionViewImageCell {
            cell.currentImageView.image = images[indexPath.row]
        }
        
        return cell
    }
}

extension CameraViewImageCollectionViewCell: CameraViewAdaptiveCell {
    func updateTrailCollection(_ traitCollection: UITraitCollection) {
        let isLandscape = traitCollection.horizontalSizeClass == .compact
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = isLandscape ? .horizontal : .vertical // 또는 .vertical
        self.collectionView.collectionViewLayout = layout
    }
}
