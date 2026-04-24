package com.example.twoeyesproject

import com.example.twoeyesproject.image.PhotoPickerLauncher
import com.example.twoeyesproject.image.PickerImageSourceDelegate
import kotlinx.cinterop.ExperimentalForeignApi
import platform.Photos.PHAsset
import platform.PhotosUI.PHPickerConfiguration
import platform.PhotosUI.PHPickerFilter
import platform.PhotosUI.PHPickerResult
import platform.PhotosUI.PHPickerViewController
import platform.PhotosUI.PHPickerViewControllerDelegateProtocol
import platform.UIKit.UIApplication
import platform.darwin.NSObject

@OptIn(ExperimentalForeignApi::class)
class PhotoPickerDelegate(
    private val imageSourceDelegate: PickerImageSourceDelegate
): NSObject(), PHPickerViewControllerDelegateProtocol {
    fun presentPicker() {
        val configuration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.imagesFilter
        val controller = PHPickerViewController(configuration)
        controller.delegate = this
        UIApplication.sharedApplication.keyWindow?.rootViewController
            ?.presentViewController(controller, true, null)
    }

    override fun picker(
        picker: PHPickerViewController,
        didFinishPicking: List<*>
    ) {
        picker.dismissViewControllerAnimated(true, null)

        val results = didFinishPicking as? List<PHPickerResult> ?: return
        val identifiers: List<String> = results.mapNotNull { it.assetIdentifier }
        val fetchResult = PHAsset.fetchAssetsWithLocalIdentifiers(identifiers, options = null)
        fetchResult.enumerateObjectsUsingBlock { asset, _, _ ->
            if (asset is PHAsset) {
                imageSourceDelegate.addImageSource(asset)
            }
        }
    }
}

class PlatformPhotoPickerLauncher(
    imageSourceDelegate: PickerImageSourceDelegate
): PhotoPickerLauncher {
    private val delegate = PhotoPickerDelegate(imageSourceDelegate)
    override fun launch() {
        delegate.presentPicker()
    }
}
