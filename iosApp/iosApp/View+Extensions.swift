//
//  View+Extensions.swift
//  iosApp
//
//  Created by 백상휘 on 6/26/26.
//

import Shared

var thumbnailWidth: CGFloat {
    CGFloat(AppConstants.shared.THUMBNAIL_SIZE_WIDTH)
}
var thumbnailHeight: CGFloat {
    CGFloat(AppConstants.shared.THUMBNAIL_SIZE_HEIGHT)
}
var thumbnailSize: CGSize {
    CGSize(width: thumbnailWidth, height: thumbnailHeight)
}
var iconWidth: CGFloat {
    CGFloat(AppConstants.shared.ICON_SIZE_WIDTH)
}
var iconHeight: CGFloat {
    CGFloat(AppConstants.shared.ICON_SIZE_HEIGHT)
}
var iconSize: CGSize {
    CGSize(width: iconWidth, height: iconHeight)
}
