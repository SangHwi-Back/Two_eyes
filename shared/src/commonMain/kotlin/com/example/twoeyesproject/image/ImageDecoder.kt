package com.example.twoeyesproject.image

expect class ImageDecoder(imageSource: ImageSource) {
    suspend fun decode(source: ImageSource): PlatformImage
}