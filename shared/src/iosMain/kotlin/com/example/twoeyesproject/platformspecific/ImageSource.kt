package com.example.twoeyesproject.platformspecific

import platform.Photos.PHAsset

actual typealias ImageSource = PHAsset

actual fun String.toImageSource(): ImageSource? {
    val fetchResult = PHAsset.fetchAssetsWithLocalIdentifiers(listOf(this), null)
    return fetchResult.firstObject as PHAsset?
}