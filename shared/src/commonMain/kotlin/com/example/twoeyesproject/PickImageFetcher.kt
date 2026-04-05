package com.example.twoeyesproject

import com.example.twoeyesproject.image.PlatformImage

expect class PickImageFetcher(viewModel: PickImageViewModel) {
    suspend fun loadPlatformImages(): List<PlatformImage>
}