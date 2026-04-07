package com.example.twoeyesproject.image

import com.example.twoeyesproject.platformspecific.PlatformImage

// Rect 추상화
data class ImageFrame(
    var left: Float,
    var top: Float,
    var right: Float,
    var bottom: Float,
) {
    fun setPosition(x: Float, y: Float) {
        left = x
        right += x
        top = y
        bottom += y
    }
}

// Image 머징 모델
data class ImageMergerModel(
    val canvasWidth: Int,
    val canvasHeight: Int,
    val bottomImage: ImageInfo,
    val topImage: ImageInfo,
    val blendAlpha: Float = 0.5f,
) {
    data class ImageInfo(
        val image: PlatformImage,
        val frame: ImageFrame
    )
}

expect class ImageMerger() {
    fun merge(model: ImageMergerModel): PlatformImage
}