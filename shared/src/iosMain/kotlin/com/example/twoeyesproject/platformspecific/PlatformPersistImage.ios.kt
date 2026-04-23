package com.example.twoeyesproject.platformspecific

import kotlinx.cinterop.ExperimentalForeignApi
import platform.Photos.PHAsset
import platform.Photos.PHAssetChangeRequest
import platform.Photos.PHPhotoLibrary
import platform.darwin.dispatch_async
import platform.darwin.dispatch_get_main_queue

@OptIn(ExperimentalForeignApi::class)
actual class PlatformPersistImage {
    actual fun persistImage(image: PlatformImage, completionHandler: (String) -> Unit) {
        var id: String? = null
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            id = PHAssetChangeRequest
                .creationRequestForAssetFromImage(image)
                .placeholderForCreatedAsset
                ?.localIdentifier
        }) { success, _ ->
            if (!success || id == null) {
                completionHandler("")
                return@performChanges
            }

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(id!!)
            }
        }
    }
}