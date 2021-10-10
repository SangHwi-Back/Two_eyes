//
//  FilterViewImageModel.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/08/25.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import Foundation
import Photos
import UIKit

class FilterImageViewModel {
    
    var initialImage: CIImage
    var initialAsset: PHAsset
    var imageManager: PHImageManager
    var basicFilter: BasicFilterTemplate
    var filterImageSize: CGSize?
    
    init(asset: PHAsset, manager: PHImageManager, image: CIImage) {
        self.initialImage = image
        self.initialAsset = asset
        self.imageManager = manager
        self.basicFilter = BasicFilterTemplate(image: image)
    }
    
    func initiate() {
        basicFilter.filterInitiate()
    }
    
    func requestAssetImage(size: CGSize, asset: PHAsset? = nil, mode: PHImageContentMode = .aspectFit, completionHandler: @escaping (UIImage?)->Void) {
        
        let imageAsset = asset ?? initialAsset
        
        DispatchQueue.main.async { [self] in
            imageManager.requestImage(for: imageAsset, targetSize: size, contentMode: mode, options: nil) { result, _ in
                completionHandler(result)
            }
        }
    }

    func requestFilteredImage(size: CGSize, filterName: String, completionHandler: @escaping (UIImage?)->Void) {
        
        self.requestAssetImage(size: size) { [self] image in
            
            if let image = image, let ciImage = CIImage(image: image) {
                basicFilter.filterName = filterName
                basicFilter.needToFilterCIImage = ciImage
                completionHandler(UIImage(ciImage: basicFilter.filteredImage))
            }
        }
    }
    
    func adjustingFilteredImage(key: FilterAdjustKey, value: Float, image: UIImage, completionHandler: @escaping (UIImage?)->Void) {
        
        if let ciImage = image.ciImage {
            self.basicFilter.adjustKey = key
            self.basicFilter.adjustingValueChange(as: ciImage, for: value) { image in
                if let ciImage = image {
                    completionHandler(UIImage(ciImage: ciImage))
                }
            }
        }
    }
}
