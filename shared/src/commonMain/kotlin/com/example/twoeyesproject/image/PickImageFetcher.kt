package com.example.twoeyesproject.image

import com.example.twoeyesproject.platformspecific.ImageSource
import com.example.twoeyesproject.platformspecific.PlatformImage

expect class PickImageFetcher() {
    suspend fun loadPlatformSourceOfImages(): List<ImageSource>
    suspend fun loadImageUsingSource(source: ImageSource): PlatformImage?
}