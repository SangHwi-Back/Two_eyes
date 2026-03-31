package com.example.twoeyesproject.image

expect class ImageDecoder constructor() {
    suspend fun decode(source: ImageSource): PlatformImage
}