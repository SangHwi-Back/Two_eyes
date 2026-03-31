package com.example.twoeyesproject.image

import android.graphics.Bitmap
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

@RunWith(RobolectricTestRunner::class)
class ImageMergerAndroidTest {
    private val merger = ImageMerger()

    @Test
    fun `겹치지 않는 두 이미지를 합치면 결과물 크기가 캔버스와 같다`() {
        val model = ImageMergerModel(
            canvasWidth = 200,
            canvasHeight = 100,
            bottomImage = ImageMergerModel.ImageInfo(
                image = Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888),
                frame = ImageFrame(0f, 0f, 100f, 100f)
            ),
            topImage = ImageMergerModel.ImageInfo(
                image = Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888),
                frame = ImageFrame(100f, 0f, 200f, 100f) // 안 겹침
            )
        )

        val result = merger.merge(model)
        assertNotNull(result)
        assertEquals(200, result.width)
        assertEquals(100, result.height)
    }
}