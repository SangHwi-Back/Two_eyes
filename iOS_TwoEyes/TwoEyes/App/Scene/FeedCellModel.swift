//
//  FeedCellModel.swift
//  PhotoApp
//
//  Created by SangHwiBack on 2/27/26.
//

import UIKit

nonisolated enum FeedCell: Hashable, Sendable {
    case thumbnail(FeedThumbnail)
    case contents(FeedContents)
}

struct FeedThumbnail: Hashable, Sendable {
    let firstImage: Image
    let secondImage: Image?
    
    struct Image: Hashable {
        static func == (lhs: FeedThumbnail.Image, rhs: FeedThumbnail.Image) -> Bool {
            lhs.imagePath == rhs.imagePath
        }
        
        let image: UIImage
        let imagePath: String
    }
}

struct FeedContents: Hashable {
    let title: String
    let contents: String
}

nonisolated enum FeedSection: Hashable {
    case list
}
