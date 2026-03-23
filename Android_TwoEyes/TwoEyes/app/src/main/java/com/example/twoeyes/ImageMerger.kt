package com.example.twoeyes

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PointF
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.Region

class ImageMerger {
    fun merge(model: ImageMergerModel): Bitmap {
        val result = Bitmap.createBitmap(
            model.canvasWidth, model.canvasHeight, Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(result)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        val bottom = model.bottomBitmap
        val top = model.topBitmap

        paint.alpha = 255
        canvas.drawBitmap(bottom.bitmap, null, bottom.frame, paint)

        val intersection = RectF()
        val hasOverlap = intersection.setIntersect(bottom.frame, top.frame)

        if (!hasOverlap) {
            canvas.drawBitmap(top.bitmap, null, top.frame, paint)
            return result
        }

        paint.alpha = 255
        canvas.save()

        val topRegion = Region(top.frame.toRect())
        val overlapRegion = Region(intersection.toRect())
        topRegion.op(overlapRegion, Region.Op.DIFFERENCE)

        canvas.drawRegion(topRegion, paint)
        canvas.drawBitmap(top.bitmap, null, top.frame, paint)
        canvas.restore()

        paint.alpha = model.blendAlpha
        canvas.save()
        canvas.clipRect(intersection)
        canvas.drawBitmap(top.bitmap, null, top.frame, paint)
        canvas.restore()

        return result
    }

    private fun RectF.toRect() = Rect(
        left.toInt(), top.toInt(), right.toInt(), bottom.toInt()
    )
}

data class MergeTarget(
    val bitmap: Bitmap,
    val position: PointF,
)

data class ImageMergerModel(
    val canvasWidth: Int,
    val canvasHeight: Int,
    val bottomBitmap: BitmapInfo,
    val topBitmap: BitmapInfo,
    val blendAlpha: Int = 128 // 0~255, 128 = 50%
) {
    data class BitmapInfo(
        val bitmap: Bitmap,
        val frame: RectF
    )
}