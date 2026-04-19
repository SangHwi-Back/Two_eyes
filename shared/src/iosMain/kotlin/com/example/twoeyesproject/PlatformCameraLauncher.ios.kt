package com.example.twoeyesproject

import com.example.twoeyesproject.image.CameraLauncher
import com.example.twoeyesproject.image.PickImageViewModel
import kotlinx.cinterop.ExperimentalForeignApi
import platform.Photos.PHAsset
import platform.Photos.PHAssetChangeRequest
import platform.Photos.PHPhotoLibrary
import platform.UIKit.UIApplication
import platform.UIKit.UIImage
import platform.UIKit.UIImagePickerController
import platform.UIKit.UIImagePickerControllerDelegateProtocol
import platform.UIKit.UIImagePickerControllerOriginalImage
import platform.UIKit.UIImagePickerControllerSourceType
import platform.UIKit.UINavigationControllerDelegateProtocol
import platform.darwin.dispatch_async
import platform.darwin.dispatch_get_main_queue
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

        // 카메라 촬영 시 UIImagePickerControllerPHAsset 은 nil — UIImage 로 받아야 함
        val image = didFinishPickingMediaWithInfo[UIImagePickerControllerOriginalImage]
            as? UIImage ?: return

        // Photos 라이브러리에 저장 후 PHAsset 으로 변환
        var savedIdentifier: String? = null

        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            savedIdentifier = PHAssetChangeRequest
                .creationRequestForAssetFromImage(image)
                .placeholderForCreatedAsset
                ?.localIdentifier
        }) { success, _ ->
            if (!success) return@performChanges
            val id = savedIdentifier ?: return@performChanges

            val fetchResult = PHAsset.fetchAssetsWithLocalIdentifiers(listOf(id), null)
            val asset = fetchResult.firstObject as? PHAsset ?: return@performChanges

            // ViewModel 호출은 메인 스레드에서
            dispatch_async(dispatch_get_main_queue()) {
                if (viewModel.isGalleryLoaded.value) {
                    viewModel.setImageFromSource(asset)
                } else {
                    viewModel.setCameraImage(asset)
                }
            }
        }
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
