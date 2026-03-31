package com.example.twoeyesproject.image

import kotlinx.cinterop.ExperimentalForeignApi
import platform.UIKit.UIImage
import kotlin.test.Test
import kotlin.test.assertNotNull

@OptIn(ExperimentalForeignApi::class)
class ImageMergerIosTest {

    private val merger = ImageMerger()

    @Test
    fun `겹치지 않는 두 이미지를 합치면 결과가 null이 아니다`() {
        val model = ImageMergerModel(
            canvasWidth = 200,
            canvasHeight = 100,
            bottomImage = ImageMergerModel.ImageInfo(
                image = makeImage(100.0, 100.0),
                frame = ImageFrame(0f, 0f, 100f, 100f)
            ),
            topImage = ImageMergerModel.ImageInfo(
                image = makeImage(100.0, 100.0),
                frame = ImageFrame(100f, 0f, 200f, 100f)
            )
        )

        val result = merger.merge(model)
        assertNotNull(result)
    }

    private fun makeImage(width: Double, height: Double): UIImage {
        val renderer = platform.UIKit.UIGraphicsImageRenderer(
            size = platform.CoreGraphics.CGSizeMake(width, height)
        )
        return renderer.imageWithActions { }
    }
}
