package com.example.twoeyesproject.platformspecific

import kotlinx.coroutines.CompletionHandler

expect class PlatformPersistImage() {
    fun persistImage(image: PlatformImage, completionHandler: (String) -> Unit)
}