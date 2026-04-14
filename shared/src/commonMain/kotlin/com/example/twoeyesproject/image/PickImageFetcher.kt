package com.example.twoeyesproject.image

import com.example.twoeyesproject.platformspecific.ImageSource

expect class PickImageFetcher(viewModel: PickImageViewModel) {
    suspend fun loadPlatformSourceOfImages(): List<ImageSource>
}