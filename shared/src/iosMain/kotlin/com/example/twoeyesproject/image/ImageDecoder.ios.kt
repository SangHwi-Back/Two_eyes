package com.example.twoeyesproject.image

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.CoreGraphics.CGSizeMake
import platform.Photos.PHImageContentModeAspectFill
import platform.Photos.PHImageManager
import platform.Photos.PHImageRequestOptions
import platform.Photos.PHImageRequestOptionsDeliveryModeHighQualityFormat
import platform.Photos.PHImageRequestOptionsResizeModeExact
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

actual class ImageDecoder actual constructor(imageSource: ImageSource) {
    @OptIn(ExperimentalForeignApi::class)
    actual suspend fun decode(source: ImageSource): PlatformImage {
        val manager = PHImageManager.defaultManager()
        val options = PHImageRequestOptions()

        options.synchronous = false
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat
        options.resizeMode = PHImageRequestOptionsResizeModeExact
        options.networkAccessAllowed = true

        return suspendCancellableCoroutine { continuation ->
            manager.requestImageForAsset(
                source,
                CGSizeMake(100.toDouble(), 100.toDouble()),
                contentMode = PHImageContentModeAspectFill,
                options = options
            ) { image, _ ->
                if (image == null) {
                    continuation.resumeWithException(NullPointerException())
                } else {
                    continuation.resume(image)
                }
            }
        }
    }
}