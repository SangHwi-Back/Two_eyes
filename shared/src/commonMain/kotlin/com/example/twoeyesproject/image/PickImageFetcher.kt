package com.example.twoeyesproject.image

import com.example.twoeyesproject.platformspecific.ImageSource

expect class PickImageFetcher() {
    suspend fun loadPlatformSourceOfImages(): List<ImageSource>
}