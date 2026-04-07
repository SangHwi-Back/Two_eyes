package com.example.twoeyesproject.image

import com.example.twoeyesproject.platformspecific.ImageSource
import com.example.twoeyesproject.platformspecific.PlatformImage

expect class ImageDecoder() {
    suspend fun decode(source: ImageSource): PlatformImage
}