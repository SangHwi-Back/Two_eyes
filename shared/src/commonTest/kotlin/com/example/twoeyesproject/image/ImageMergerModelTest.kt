package com.example.twoeyesproject.image

import kotlin.test.Test
import kotlin.test.assertEquals

class ImageMergerModelTest {
    @Test
    fun `ImageFrame 좌표가 올바르게 저장된다`() {
        val frame = ImageFrame(0f, 0f, 100f, 200f)
        assertEquals(100f, frame.right)
        assertEquals(200f, frame.bottom)
    }

    @Test
    fun `blendAlpha 기본값은 0_5이다`() {
        val model = ImageMergerModel(
            canvasWidth = 100,
            canvasHeight = 100,
            bottomImage = ImageMergerModel.ImageInfo(TODO(), ImageFrame(0f, 0f, 100f, 100f)),
            topImage = ImageMergerModel.ImageInfo(TODO(), ImageFrame(0f, 0f, 100f, 100f)),
        )
        assertEquals(0.5f, model.blendAlpha)
    }
}