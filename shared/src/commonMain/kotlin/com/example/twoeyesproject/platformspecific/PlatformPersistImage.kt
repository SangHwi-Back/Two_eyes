package com.example.twoeyesproject.platformspecific

expect class PlatformPersistImage() {
    fun persistImage(image: PlatformImage)
}