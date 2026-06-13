package com.example.twoeyesproject.platformspecific

import com.example.twoeyesproject.image.merge.PickImageMergeViewModel
import kotlinx.cinterop.ExperimentalForeignApi
import platform.CoreImage.CIContext
import platform.CoreImage.CIFilter
import platform.CoreImage.CIImage
import platform.CoreImage.createCGImage
import platform.CoreImage.filterWithName
import platform.CoreImage.kCIInputContrastKey
import platform.CoreImage.kCIInputImageKey
import platform.CoreImage.kCIInputIntensityKey
import platform.CoreImage.kCIInputRadiusKey
import platform.CoreImage.kCIInputSaturationKey
import platform.Foundation.setValue
import platform.UIKit.UIImage
import platform.UIKit.UIImagePNGRepresentation

@OptIn(ExperimentalForeignApi::class)
actual class PlatformApplyFilter {
    val ciContext = CIContext()
    actual fun appleApplyFilter(
        image: PlatformImage,
        filter: PickImageMergeViewModel.ImageState.Filter?
    ): PlatformImage {
        if (filter == null)
            return image
        val data = UIImagePNGRepresentation(image)
            ?: return image
        val ciImage = CIImage.imageWithData(data)
            ?: return image

        val result: CIImage = when (filter) {
            PickImageMergeViewModel.ImageState.Filter.INVERTED ->
                applyCIImageInverted(ciImage) ?: return image

            PickImageMergeViewModel.ImageState.Filter.MONOCHROME ->
                applyCIImageMonochrome(ciImage) ?: return image

            PickImageMergeViewModel.ImageState.Filter.CONTRAST ->
                applyCIImageContrast(ciImage) ?: return image

            PickImageMergeViewModel.ImageState.Filter.SATURATION ->
                applyCIImageSaturation(ciImage) ?: return image

            PickImageMergeViewModel.ImageState.Filter.VIGNETTE ->
                applyCIImageVignette(ciImage) ?: return image
        }

        // result.extent 사용: CIPhotoEffectMono, CIColorControls 등은 출력 extent가
        // 입력과 달라질 수 있으므로 원본 ciImage.extent를 쓰면 잘못된 영역이 잘림.
        val cgImage = ciContext.createCGImage(result, result.extent)
            ?: return image

        // CGImage → UIImage 직접 변환 (CIImage 재래핑 불필요 — 이미 렌더링된 CGImage 사용)
        return UIImage.imageWithCGImage(cgImage, image.scale, image.imageOrientation)
    }

    private fun applyCIImageInverted(ciImage: CIImage): CIImage? {
        val filter = CIFilter.filterWithName(PickImageMergeViewModel.ImageState.Filter.INVERTED.ciFilterName)
        filter?.setValue(ciImage, kCIInputImageKey)
        return filter?.outputImage
    }

    private fun applyCIImageMonochrome(ciImage: CIImage): CIImage? {
        val filter = CIFilter.filterWithName(PickImageMergeViewModel.ImageState.Filter.MONOCHROME.ciFilterName)
        filter?.setValue(ciImage, kCIInputImageKey)
        return filter?.outputImage
    }

    private fun applyCIImageContrast(ciImage: CIImage): CIImage? {
        val filter = CIFilter.filterWithName(PickImageMergeViewModel.ImageState.Filter.CONTRAST.ciFilterName)
        filter?.setValue(ciImage, kCIInputImageKey)
        filter?.setValue(1.5, kCIInputContrastKey)
        return filter?.outputImage
    }

    private fun applyCIImageSaturation(ciImage: CIImage): CIImage? {
        val filter = CIFilter.filterWithName(PickImageMergeViewModel.ImageState.Filter.SATURATION.ciFilterName)
        filter?.setValue(ciImage, kCIInputImageKey)
        filter?.setValue(2.5, kCIInputSaturationKey)
        return filter?.outputImage
    }

    private fun applyCIImageVignette(ciImage: CIImage): CIImage? {
        val filter = CIFilter.filterWithName(PickImageMergeViewModel.ImageState.Filter.VIGNETTE.ciFilterName)
        filter?.setValue(ciImage, kCIInputImageKey)
        filter?.setValue(1.5, kCIInputIntensityKey)
        filter?.setValue(1.0, kCIInputRadiusKey)
        return filter?.outputImage
    }

    private val PickImageMergeViewModel.ImageState.Filter.ciFilterName: String
        get() = when (this) {
            PickImageMergeViewModel.ImageState.Filter.INVERTED   -> "CIColorInvert"
            PickImageMergeViewModel.ImageState.Filter.MONOCHROME -> "CIPhotoEffectMono"
            PickImageMergeViewModel.ImageState.Filter.CONTRAST   -> "CIColorControls"
            PickImageMergeViewModel.ImageState.Filter.SATURATION -> "CIColorControls"
            PickImageMergeViewModel.ImageState.Filter.VIGNETTE   -> "CIVignette"
        }

    /**
     * NO Action
     */
    actual fun googleApplyFilter(
        image: PlatformImage,
        filter: PickImageMergeViewModel.ImageState.Filter?
    ): PlatformImage {
        return image
    }
}