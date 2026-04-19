package com.example.twoeyesproject

import com.example.twoeyesproject.image.CameraLauncher
import com.example.twoeyesproject.image.PickImageViewModel
import kotlinx.cinterop.ExperimentalForeignApi
import platform.Photos.PHAsset
import platform.UIKit.UIApplication
import platform.UIKit.UIImagePickerController
import platform.UIKit.UIImagePickerControllerDelegateProtocol
import platform.UIKit.UIImagePickerControllerPHAsset
import platform.UIKit.UIImagePickerControllerSourceType
import platform.UIKit.UINavigationControllerDelegateProtocol
import platform.darwin.NSObject

// Objective-C 델리게이트: NSObject + ObjC 프로토콜만 상속
@OptIn(ExperimentalForeignApi::class)
private class CameraPickerDelegate(
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

        UIApplication.sharedApplication.keyWindow?.rootViewController
            ?.presentViewController(picker, true, null)
    }

    override fun imagePickerController(
        picker: UIImagePickerController,
        didFinishPickingMediaWithInfo: Map<Any?, *>
    ) {
        picker.dismissViewControllerAnimated(true, null)

        val imageSource = didFinishPickingMediaWithInfo[UIImagePickerControllerPHAsset]
            as? PHAsset ?: return

        viewModel.setCameraImage(imageSource)
    }

    override fun imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, null)
    }
}

// Kotlin 인터페이스만 구현: ObjC 타입 없음
class PlatformCameraLauncher(
    viewModel: PickImageViewModel
) : CameraLauncher {
    private val delegate = CameraPickerDelegate(viewModel)

    override fun launch() {
        delegate.presentPicker()
    }
}
