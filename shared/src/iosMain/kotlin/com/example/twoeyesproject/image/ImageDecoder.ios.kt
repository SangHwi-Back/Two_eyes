@file:OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)

package com.example.twoeyesproject.image

import com.example.twoeyesproject.platformspecific.ImageSource
import com.example.twoeyesproject.platformspecific.PlatformImage
import com.example.twoeyesproject.platformspecific.PlatformUri
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.CoreGraphics.CGSizeMake
import platform.Photos.PHImageContentModeAspectFill
import platform.Photos.PHImageManager
import platform.Photos.PHImageRequestOptions
import platform.Photos.PHImageRequestOptionsDeliveryModeHighQualityFormat
import platform.Photos.PHImageRequestOptionsResizeModeExact
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

actual class ImageDecoder {
    actual suspend fun decode(source: PlatformUri): PlatformImage {
        val manager = PHImageManager.defaultManager()
        val options = PHImageRequestOptions()

        options.synchronous = false
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat
        options.resizeMode = PHImageRequestOptionsResizeModeExact
        options.networkAccessAllowed = true

        return suspendCancellableCoroutine { continuation ->
            val requestId = manager.requestImageForAsset(
                source,
                CGSizeMake(100.toDouble(), 100.toDouble()),
                contentMode = PHImageContentModeAspectFill,
                options = options
            ) { image, _ ->
                if (image == null) {
                    continuation.resumeWithException(NullPointerException("Failed to decode image"))
                } else {
                    continuation.resume(image)
                }
            }

            continuation.invokeOnCancellation {
                manager.cancelImageRequest(requestId)
            }
        }
    }
}
