package com.example.twoeyesproject.image

import com.example.twoeyesproject.platformspecific.ImageSource
import com.example.twoeyesproject.platformspecific.PlatformImage
import kotlinx.cinterop.CValue
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.CoreGraphics.CGSize
import platform.CoreGraphics.CGSizeMake
import platform.Foundation.NSPredicate
import platform.Foundation.NSSortDescriptor
import platform.Photos.PHAccessLevelReadWrite
import platform.Photos.PHAsset
import platform.Photos.PHAssetMediaTypeImage
import platform.Photos.PHAuthorizationStatusAuthorized
import platform.Photos.PHAuthorizationStatusLimited
import platform.Photos.PHAuthorizationStatusNotDetermined
import platform.Photos.PHFetchOptions
import platform.Photos.PHImageContentModeAspectFill
import platform.Photos.PHImageManager
import platform.Photos.PHImageRequestOptions
import platform.Photos.PHImageRequestOptionsDeliveryModeHighQualityFormat
import platform.Photos.PHPhotoLibrary
import platform.UIKit.UIImage
import kotlin.coroutines.resume

@OptIn(ExperimentalForeignApi::class)
actual class PickImageFetcher actual constructor(val viewModel: PickImageViewModel) {
    suspend fun requestPhotoLibraryPermission(): Boolean {
        val status = PHPhotoLibrary.authorizationStatusForAccessLevel(
            PHAccessLevelReadWrite
        )

        if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
            return true
        } else if (status == PHAuthorizationStatusNotDetermined) {
            return suspendCancellableCoroutine { continuation ->
                PHPhotoLibrary.requestAuthorizationForAccessLevel(PHAccessLevelReadWrite) {
                    val result =
                        (it == PHAuthorizationStatusAuthorized || it == PHAuthorizationStatusLimited)
                    continuation.resume(result)
                }
            }
        }

        return false
    }

    actual suspend fun loadPlatformSourceOfImages(): List<ImageSource> {
        val permissionResult = requestPhotoLibraryPermission()

        if (permissionResult.not()) {
            throw UnsupportedOperationException("사진 접근 권한이 없습니다.")
        }

        val assets = fetchAllPhotos()
        return assets
    }

    private fun fetchAllPhotos(): List<PHAsset> {
        val assets = mutableListOf<PHAsset>()
        val fetchOptions = PHFetchOptions()

        fetchOptions.sortDescriptors = listOf(NSSortDescriptor("creationDate", false))
        fetchOptions.predicate =
            NSPredicate.predicateWithFormat("mediaType == %d", PHAssetMediaTypeImage)

        val result = PHAsset.fetchAssetsWithOptions(fetchOptions)

        result.enumerateObjectsUsingBlock { asset, _, _ ->
            if (asset is PHAsset) {
                assets.add(asset)
            }
        }
        return assets.toList()
    }

    // MARK: - PHAsset → UIImage 변환
    suspend fun convertToUIImages(
        assets: List<PHAsset>,
        targetSize: CValue<CGSize> = CGSizeMake(300.0, 300.0),
    ): List<PlatformImage> {
        val imageManager = PHImageManager.defaultManager()

        val options = PHImageRequestOptions()
        options.synchronous = true
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat
        options.networkAccessAllowed = true

        var images = mutableListOf<PlatformImage>()

        for (asset in assets) {
            val image = suspendCancellableCoroutine { continuation ->
                imageManager.requestImageForAsset(
                    asset,
                    targetSize = targetSize,
                    contentMode = PHImageContentModeAspectFill,
                    options = options,
                    resultHandler = { image: UIImage?, _ ->
                        continuation.resume(image)
                    }
                )
            }

            if (image != null) {
                images.add(image)
            }
        }

        return images
    }
}