//
//  SearchAndLoadCollectionViewCell.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/12.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit

class SearchAndLoadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var livePhotoBadgeImageView: UIImageView!
    @IBOutlet var imageView: UIImageView!
    
    var representAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    var livePhotoBadgeImage: UIImage! {
        didSet {
            livePhotoBadgeImageView.image = livePhotoBadgeImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        livePhotoBadgeImageView.image = nil
    }
}
