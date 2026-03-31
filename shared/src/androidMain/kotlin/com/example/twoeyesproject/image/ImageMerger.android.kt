package com.example.twoeyesproject.image

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Region
import androidx.core.graphics.createBitmap
import androidx.core.graphics.withClip

actual class ImageMerger actual constructor() {
    actual fun merge(model: ImageMergerModel): PlatformImage {
        val result = createBitmap(model.canvasWidth, model.canvasHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(result)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        val bottom = model.bottomImage
        val top = model.topImage

        paint.alpha = 255
        canvas.drawBitmap(bottom.image, null, bottom.frame.toRectF(), paint)

        val intersection = RectF()
        val hasOverlap = intersection.setIntersect(bottom.frame.toRectF(), top.frame.toRectF())

        if (!hasOverlap) {
            canvas.drawBitmap(top.image, null, top.frame.toRectF(), paint)
            return result
        }

        // top 이미지의 겹치지 않는 영역만 그리기 (intersection 제외)
        paint.alpha = 255
        canvas.withClip(top.frame.toRectF()) {
            @Suppress("DEPRECATION")
            clipRect(intersection, Region.Op.DIFFERENCE) // API 26+는 clipOutRect()지만 24 호환 위해 유지
            drawBitmap(top.image, null, top.frame.toRectF(), paint)
        }

        // 겹치는 영역을 blendAlpha 로 그리기
        paint.alpha = (model.blendAlpha * 255).toInt()
        canvas.withClip(intersection) {
            drawBitmap(top.image, null, top.frame.toRectF(), paint)
        }

        return result
    }

    private fun ImageFrame.toRectF() = RectF(left, top, right, bottom)
}