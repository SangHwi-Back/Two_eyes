package com.example.twoeyesproject

import com.example.twoeyesproject.image.PhotoPickerLauncher
import com.example.twoeyesproject.image.PickImageViewModel
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
    private val viewModel: PickImageViewModel
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
        val imageSource = mutableListOf<PHAsset>()
        val fetchResult = PHAsset.fetchAssetsWithLocalIdentifiers(identifiers, options = null)
        fetchResult.enumerateObjectsUsingBlock { asset, index, stop ->
            if (asset is PHAsset) {
                imageSource.add(asset)
            }
        }
    }
}

class PlatformPhotoPickerLauncher(
    viewModel: PickImageViewModel
): PhotoPickerLauncher {
    private val delegate = PhotoPickerDelegate(viewModel)
    override fun launch() {
        delegate.presentPicker()
    }
}
