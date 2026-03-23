//
//  ImageMerger.swift
//  TwoEyes
//
//  Created by 백상휘 on 3/20/26.
//

import UIKit

struct ImageMerger {
    /**
     1. Image 를 겹친 부분 하나와 겹치지 않은 부분 2개 총 3개로 나눈다.
     2. 겹쳐진 부분은 Merge 한다.
     3. 겹쳐지지 않은 부분에서 Merge 한 결과물을 붙인 뒤 새로운 이미지로 만든다.
     */
    func merge(_ model: ImageMergerModel) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: model.canvasSize)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            let bottom = model.bottomImage
            let top = model.topImage
            
            bottom.image.draw(in: bottom.frame)
            
            let intersection = bottom.frame.intersection(top.frame)
            
            if intersection.isNull || intersection.isEmpty {
                top.image.draw(in: top.frame)
                return
            }
            
            let clipPath = UIBezierPath(rect: top.frame)
            clipPath.append(UIBezierPath(rect: intersection).reversing())
            clipPath.usesEvenOddFillRule = true
            
            cgContext.saveGState()
            clipPath.addClip()
            top.image.draw(in: top.frame)
            cgContext.restoreGState()
            
            cgContext.saveGState()
            cgContext.clip(to: intersection)
            top.image.draw(in: top.frame, blendMode: .normal, alpha: model.blendAlpha)
            cgContext.restoreGState()
        }
    }
}

struct ImageMergerModel {
    struct ImageInfo {
        let image: UIImage
        let frame: CGRect
    }
    let canvasSize: CGSize
    let topImage: ImageInfo
    let bottomImage: ImageInfo
    
    var blendAlpha: CGFloat = 0.5
}
