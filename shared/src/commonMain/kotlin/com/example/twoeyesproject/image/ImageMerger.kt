package com.example.twoeyesproject.image

// Rect 추상화
data class ImageFrame(
    val left: Float,
    val top: Float,
    val right: Float,
    val bottom: Float,
)

// Image 머징 모델
data class ImageMergerModel(
    val canvasWidth: Int,
    val canvasHeight: Int,
    val bottomImage: ImageInfo,
    val topImage: ImageInfo,
    val blendAlpha: Int = 128 // 0~255, 128 = 50%
) {
    data class ImageInfo(
        val image: PlatformImage,
        val frame: ImageFrame
    )
}

expect class ImageMerger() {
    fun merge(model: ImageMergerModel): PlatformImage
}