package com.example.twoeyesproject.image

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.core.net.toUri
import com.example.twoeyesproject.platformspecific.ImageSource
import com.example.twoeyesproject.platformspecific.PlatformImage
import com.example.twoeyesproject.platformspecific.convertToString
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.koin.core.component.KoinComponent
import org.koin.core.component.get
import java.net.URLDecoder
import java.nio.charset.StandardCharsets

actual class ImageDecoder : KoinComponent {
    actual suspend fun decode(source: ImageSource): PlatformImage {
        val context: Context = get()
        val urlString = withContext(Dispatchers.IO) {
            URLDecoder.decode(source.convertToString(), StandardCharsets.UTF_8.name())
        }
        return try {
            getResizedBitmapFromUri(context, urlString.toUri(), 1024, 1024)
                ?: throw Exception("Failed to decode image from source")
        } catch (e: Exception) {
            e.printStackTrace()
            throw Exception("Failed to decode image from source")
        }
    }

    fun getResizedBitmapFromUri(context: Context, uri: Uri, reqWidth: Int, reqHeight: Int): Bitmap? {
        try {
            // 1. 이미지 크기만 먼저 확인 (메모리 할당 X)
            val options = BitmapFactory.Options()
            options.inJustDecodeBounds = true

            context.getContentResolver().openInputStream(uri).use { input ->
                BitmapFactory.decodeStream(input, null, options)
            }
            // 2. 축소 비율(inSampleSize) 계산 (예: 2의 거듭제곱인 2, 4, 8 등)
            options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight)

            // 3. 실제 축소된 비트맵을 메모리에 로드
            options.inJustDecodeBounds = false
            context.getContentResolver().openInputStream(uri).use { input ->
                return BitmapFactory.decodeStream(input, null, options)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val height = options.outHeight
        val width = options.outWidth
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2

            while ((halfHeight / inSampleSize) >= reqHeight && (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2
            }
        }
        return inSampleSize
    }
}
