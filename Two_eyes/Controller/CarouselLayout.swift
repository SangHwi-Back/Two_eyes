//
//  CarouselLayout.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/08/17.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

class CarouselLayout: UICollectionViewFlowLayout {
    
    public var sideItemScale: CGFloat = 0.5
    public var sideItemAlpha: CGFloat = 0.8
    public var spacing: CGFloat = 16
    
    public var isPagingEnabled = false
    
    private var isSetup = false
    
    override func prepare() {
        super.prepare()
        
        if isSetup == false {
            setupLayout()
            isSetup.toggle()
        }
    }
    
    func setupLayout() {
        
        guard collectionView != nil else {
            return
        }
        
        let itemWidth = itemSize.width
        
        let scaledItemOffset = (itemWidth - itemWidth * self.sideItemScale) / 2
        minimumLineSpacing = spacing - scaledItemOffset
        scrollDirection = .horizontal
        
        let insetX = itemSize.width
        let insetY = itemSize.height / 5
        
        sectionInset = UIEdgeInsets(
            top: insetY,
            left: (insetX + minimumLineSpacing) * 3,
            bottom: insetY,
            right: (insetX + minimumLineSpacing) * 3
        )
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        return superAttributes.map({ self.transformLayoutAttributes(attribute: $0) })
    }
    
    private func transformLayoutAttributes(attribute: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        guard let collectionView = self.collectionView else {
            return attribute
        }
        
        let collectionCenter = collectionView.frame.size.width / 2
        let contentOffset = collectionView.contentOffset.x
        let center = attribute.center.x - contentOffset
        
        let maxDistance = self.itemSize.width + self.minimumLineSpacing
        let distance = min(abs(collectionCenter - center), maxDistance)
        
        let ratio = (maxDistance - distance) / maxDistance
        let scale = ratio * (1-0.7) + 0.7
        attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
//        let alpha = admitRatio(ratio, value: self.sideItemAlpha)
//        let scale = admitRatio(ratio, value: self.sideItemScale)
//
//        attribute.alpha = alpha
//        attribute.setTransform3D(collectionView, scale: scale)
        
        return attribute
    }
    
    func admitRatio(_ ratio: CGFloat, value: CGFloat) -> CGFloat {
        return ratio * (1 - value) + value
    }
}
extension UICollectionViewLayoutAttributes {
    func setTransform3D(_ collectionView: UICollectionView, scale: CGFloat) {
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let dist = self.frame.midX - visibleRect.midX
        let transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        
        self.transform3D = CATransform3DTranslate(transform, 0, 0, -abs(dist / 1000))
    }
}

extension CarouselLayout: UICollectionViewDelegateFlowLayout {
    
}
