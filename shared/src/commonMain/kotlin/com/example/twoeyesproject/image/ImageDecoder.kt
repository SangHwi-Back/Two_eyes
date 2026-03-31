package com.example.twoeyesproject.image

expect class ImageDecoder() {
    suspend fun decode(source: ImageSource): PlatformImage
}