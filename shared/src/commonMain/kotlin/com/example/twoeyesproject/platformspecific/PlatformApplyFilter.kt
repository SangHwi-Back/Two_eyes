package com.example.twoeyesproject.platformspecific

import com.example.twoeyesproject.image.merge.PickImageMergeViewModel

expect class PlatformApplyFilter() {
    fun appleApplyFilter(image: PlatformImage, filter: PickImageMergeViewModel.ImageState.Filter?): PlatformImage
    fun googleApplyFilter(image: PlatformImage, filter: PickImageMergeViewModel.ImageState.Filter?): PlatformImage
}