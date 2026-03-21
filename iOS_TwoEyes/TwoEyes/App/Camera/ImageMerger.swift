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
    func merge(_ model: ImageMergerModel) -> [UIImage] {
        model.images.enumerated().map { (index, images) in
            let size = model.sizes[index]
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { ctx in
                // TODO: Merge Logics
            }
        }
    }
}

struct ImageMergerModel {
    var images: [UIImage]
    var sizes: [CGSize]
}
