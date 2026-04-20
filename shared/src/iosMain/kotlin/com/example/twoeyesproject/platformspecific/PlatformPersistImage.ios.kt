package com.example.twoeyesproject.platformspecific

import kotlinx.cinterop.ExperimentalForeignApi
import platform.UIKit.UIImageWriteToSavedPhotosAlbum

@OptIn(ExperimentalForeignApi::class)
actual class PlatformPersistImage {
    actual fun persistImage(image: PlatformImage) {
        UIImageWriteToSavedPhotosAlbum(
            image, null, null, null)
    }
}