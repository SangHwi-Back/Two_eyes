package com.example.twoeyesproject

import com.example.twoeyesproject.image.PlatformImage
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asSharedFlow
import platform.PhotosUI.PHPickerResult
import platform.PhotosUI.PHPickerViewController
import platform.PhotosUI.PHPickerViewControllerDelegateProtocol
import platform.UIKit.UIImage
import platform.UIKit.UIImagePickerController
import platform.UIKit.UIImagePickerControllerDelegateProtocol
import platform.UIKit.UIImagePickerControllerOriginalImage
import platform.darwin.NSObject

class ImagePickerImpl: NSObject(), UIImagePickerControllerDelegateProtocol, PHPickerViewControllerDelegateProtocol {
    private val _images = MutableStateFlow<MutableList<PlatformImage>>(mutableListOf())
    val images = _images.asSharedFlow()

    override fun imagePickerController(
        picker: UIImagePickerController,
        didFinishPickingImage: UIImage,
        editingInfo: Map<Any?, *>?
    ) {
        super.imagePickerController(picker, didFinishPickingImage, editingInfo)

        val image: PlatformImage? =
            editingInfo?.get(UIImagePickerControllerOriginalImage) as? PlatformImage

        if (image == null) return

        _images.value.add(image)
    }

    override fun picker(
        picker: PHPickerViewController,
        didFinishPicking: List<*>
    ) {
        picker.dismissViewControllerAnimated(true, null)
        didFinishPicking
            .map { it as? PHPickerResult }
            .filterNotNull().forEach {
                // TODO()
            }
    }
}