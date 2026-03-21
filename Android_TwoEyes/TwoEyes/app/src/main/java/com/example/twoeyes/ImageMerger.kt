package com.example.twoeyes

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.PointF

class ImageMerger {
    fun merge(target1: MergeTarget, target2: MergeTarget): Bitmap {
        var result = Bitmap.createBitmap(120, 120, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(result)
        return result
    }
}

data class MergeTarget(
    val bitmap: Bitmap,
    val position: PointF,
)