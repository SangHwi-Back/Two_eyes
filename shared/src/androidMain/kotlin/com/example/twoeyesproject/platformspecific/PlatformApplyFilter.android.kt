package com.example.twoeyesproject.platformspecific

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.ColorFilter
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.RadialGradient
import android.graphics.Shader
import androidx.compose.ui.graphics.ColorMatrix
import androidx.compose.ui.graphics.ColorMatrixColorFilter
import androidx.compose.ui.graphics.asAndroidColorFilter
import com.example.twoeyesproject.image.merge.PickImageMergeViewModel

actual class PlatformApplyFilter {
    /**
     * NO Action
     */
    actual fun appleApplyFilter(
        image: PlatformImage,
        filter: PickImageMergeViewModel.ImageState.Filter?
    ): PlatformImage {
        return image
    }

    actual fun googleApplyFilter(
        image: PlatformImage,
        filter: PickImageMergeViewModel.ImageState.Filter?
    ): PlatformImage {
        val mutableBitmap = image.copy(Bitmap.Config.ARGB_8888, true)

        val canvas = Canvas(mutableBitmap)
        val paint = Paint()

        fun drawBitmapWithFilter(colorFilter: ColorFilter): Bitmap {
            paint.colorFilter = getColorFilterMonochrome()
            canvas.drawBitmap(mutableBitmap, 0f, 0f, paint)
            return mutableBitmap
        }

        when (filter) {
            PickImageMergeViewModel.ImageState.Filter.INVERTED -> {
                return drawBitmapWithFilter(getColorFilterInverted())
            }
            PickImageMergeViewModel.ImageState.Filter.VIGNETTE -> {
                val centerX = canvas.width / 2f
                val centerY = canvas.height / 2f
                val radius = centerX.coerceAtLeast(centerY) * 1.2f
                val vignetteColor = 0x99000000.toInt()
                // 3. Create a RadialGradient (center fades out to the edges)
                val gradient = RadialGradient(
                    centerX, centerY, radius,
                    intArrayOf(0x00000000, 0x00000000, vignetteColor),
                    floatArrayOf(0.0f, 0.6f, 1.0f),
                    Shader.TileMode.CLAMP
                )
                paint.apply {
                    isAntiAlias = true
                    shader = gradient
                    xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_OVER)
                }
                canvas.drawRect(
                    0f, 0f,
                    canvas.width.toFloat(), canvas.height.toFloat(),
                    paint)
                return mutableBitmap
            }
            PickImageMergeViewModel.ImageState.Filter.CONTRAST -> {
                return drawBitmapWithFilter(getColorFilterContrast())
            }
            PickImageMergeViewModel.ImageState.Filter.SATURATION -> {
                return drawBitmapWithFilter(getColorFilterSaturation())
            }
            PickImageMergeViewModel.ImageState.Filter.MONOCHROME -> {
                return drawBitmapWithFilter(getColorFilterMonochrome())
            }
            else -> {
                return image
            }
        }
    }

    private fun getColorFilterInverted(): ColorFilter = ColorMatrixColorFilter(
        ColorMatrix(floatArrayOf(
            -1f, 0f, 0f, 0f, 255f,
            0f, -1f, 0f, 0f, 255f,
            0f, 0f, -1f, 0f, 255f,
            0f, 0f, 0f, 1f, 0f))
    ).asAndroidColorFilter()

    private fun getColorFilterContrast(): ColorFilter {
        val scale = 1.0f
        val translate = (-0.5f * scale + 0.5f) * 255f
        // 4x5 ColorMatrix Array
        val contrastMatrix = floatArrayOf(
            scale, 0f, 0f, 0f, translate,
            0f, scale, 0f, 0f, translate,
            0f, 0f, scale, 0f, translate,
            0f, 0f, 0f, 1f, 0f
        )
        return ColorMatrixColorFilter(
            ColorMatrix(contrastMatrix)).asAndroidColorFilter()
    }

    private fun getColorFilterSaturation(): ColorFilter = ColorMatrixColorFilter(
        ColorMatrix().apply { setToSaturation(1f) }).asAndroidColorFilter()

    private fun getColorFilterMonochrome(): ColorFilter = ColorMatrixColorFilter(
        ColorMatrix().apply { setToSaturation(0f) }).asAndroidColorFilter()
}