package com.example.twoeyesproject.image

import com.example.twoeyesproject.platformspecific.PlatformImage

expect class PickImageFetcher(viewModel: PickImageViewModel) {
    suspend fun loadPlatformImages(): List<PlatformImage>
}