package com.example.twoeyesproject

import com.example.twoeyesproject.image.CapturedImage
import com.example.twoeyesproject.image.PhotoPickerLauncher
import com.example.twoeyesproject.image.PickImageViewModel
import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSItemProviderReadingProtocol
import platform.PhotosUI.PHPickerConfiguration
import platform.PhotosUI.PHPickerFilter
import platform.PhotosUI.PHPickerResult
import platform.PhotosUI.PHPickerViewController
import platform.PhotosUI.PHPickerViewControllerDelegateProtocol
import platform.UIKit.UIApplication
import platform.UIKit.UIImage
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

        for (result in results) {
            val provider = result.itemProvider

            if (provider.canLoadObjectOfClass(UIImage::class as NSItemProviderReadingProtocol)) {
                provider.loadObjectOfClass(UIImage::class as NSItemProviderReadingProtocol) { image, error ->
                    val uiImage = image as? UIImage ?: return@loadObjectOfClass
                    if (error == null) {
                        viewModel.setCapturedImage(CapturedImage(
                            image = uiImage,
                            width = 300,
                            height = 300
                        ))
                    }
                }
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
