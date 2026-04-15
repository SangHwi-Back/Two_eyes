package com.example.twoeyesproject

import android.graphics.Bitmap
import com.example.twoeyesproject.image.ImageFrame
import com.example.twoeyesproject.image.ImageMergerModel
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import kotlin.test.Test
import kotlin.test.assertEquals

@RunWith(RobolectricTestRunner::class)
class ImageMergerModelTest {
    @Test
    fun `blendAlpha 기본값은 0_5이다`() {
        val dummyImage = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
        val model = ImageMergerModel(
            canvasWidth = 100,
            canvasHeight = 100,
            bottomImage = ImageMergerModel
                .ImageInfo(dummyImage, ImageFrame(0f, 0f, 100f, 100f)),
            topImage = ImageMergerModel
                .ImageInfo(dummyImage, ImageFrame(0f, 0f, 100f, 100f)),
        )
        assertEquals(0.5f, model.blendAlpha)
    }
}