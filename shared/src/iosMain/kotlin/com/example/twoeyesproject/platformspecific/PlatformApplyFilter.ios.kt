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
        var result: CIImage

        when (filter) {
            PickImageMergeViewModel.ImageState.Filter.INVERTED -> {
                val filter = CIFilter.filterWithName("CIColorInvert")
                filter?.setValue(ciImage, kCIInputImageKey)
                result = filter?.outputImage ?: return image
            }

            PickImageMergeViewModel.ImageState.Filter.MONOCHROME -> {
                val filter = CIFilter.filterWithName("CIPhotoEffectMono")
                filter?.setValue(ciImage, kCIInputImageKey)
                result = filter?.outputImage ?: return image
            }

            PickImageMergeViewModel.ImageState.Filter.CONTRAST -> {
                val filter = CIFilter.filterWithName("CIColorControls")
                filter?.setValue(ciImage, kCIInputImageKey)
                filter?.setValue(1.5, kCIInputContrastKey)
                result = filter?.outputImage ?: return image
            }

            PickImageMergeViewModel.ImageState.Filter.SATURATION -> {
                val filter = CIFilter.filterWithName("CIColorControls")
                filter?.setValue(ciImage, kCIInputImageKey)
                filter?.setValue(2.5, kCIInputSaturationKey)
                result = filter?.outputImage ?: return image
            }

            PickImageMergeViewModel.ImageState.Filter.VIGNETTE -> {
                val filter = CIFilter.filterWithName("CIVignette")
                filter?.setValue(ciImage, kCIInputImageKey)
                filter?.setValue(1.5, kCIInputIntensityKey)
                filter?.setValue(1.0, kCIInputRadiusKey)
                result = filter?.outputImage ?: return image
            }
        }

        val cgImage = ciContext.createCGImage(result, ciImage.extent)
            ?: return image

        return UIImage.imageWithCIImage(
            CIImage(cgImage), image.scale, image.imageOrientation)
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