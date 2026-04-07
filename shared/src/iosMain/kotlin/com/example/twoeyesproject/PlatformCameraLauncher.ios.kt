package com.example.twoeyesproject

import com.example.twoeyesproject.image.CameraLauncher
import com.example.twoeyesproject.image.CapturedImage
import com.example.twoeyesproject.image.PickImageViewModel
import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSData
import platform.UIKit.UIImage
import platform.UIKit.UIImageJPEGRepresentation
import platform.UIKit.UIImagePickerController
import platform.UIKit.UIImagePickerControllerDelegateProtocol
import platform.UIKit.UIImagePickerControllerOriginalImage
import platform.UIKit.UIImagePickerControllerSourceType
import platform.UIKit.UINavigationControllerDelegateProtocol
import platform.UIKit.UIViewController
import platform.darwin.NSObject

// Objective-C 델리게이트: NSObject + ObjC 프로토콜만 상속
@OptIn(ExperimentalForeignApi::class)
private class CameraPickerDelegate(
    private val viewController: UIViewController,
    private val viewModel: PickImageViewModel
) : NSObject(), UIImagePickerControllerDelegateProtocol, UINavigationControllerDelegateProtocol {

    fun presentPicker() {
        if (UIImagePickerController.isSourceTypeAvailable(
                UIImagePickerControllerSourceType.UIImagePickerControllerSourceTypeCamera
            ).not()
        ) {
            // 카메라 사용 불가
            return
        }

        val picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.UIImagePickerControllerSourceTypeCamera
        picker.delegate = this

        viewController.presentViewController(picker, true, null)
    }

    override fun imagePickerController(
        picker: UIImagePickerController,
        didFinishPickingMediaWithInfo: Map<Any?, *>
    ) {
        picker.dismissViewControllerAnimated(true, null)

        val image = didFinishPickingMediaWithInfo[UIImagePickerControllerOriginalImage]
            as? UIImage ?: return

        val jpegData: NSData = UIImageJPEGRepresentation(image, 0.9) ?: return
        val convertedImage = UIImage(data = jpegData)

        viewModel.onImageCaptured(
            CapturedImage(
                image = convertedImage,
                width = 300,
                height = 300
            )
        )
    }

    override fun imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, null)
    }
}

// Kotlin 인터페이스만 구현: ObjC 타입 없음
class PlatformCameraLauncher(
    viewController: UIViewController,
    viewModel: PickImageViewModel
) : CameraLauncher {
    private val delegate = CameraPickerDelegate(viewController, viewModel)

    override fun launch() {
        delegate.presentPicker()
    }
}
