package com.example.twoeyesproject.image

import android.content.Context
import android.graphics.BitmapFactory
import com.example.twoeyesproject.platformspecific.ImageSource
import com.example.twoeyesproject.platformspecific.PlatformImage
import org.koin.core.component.KoinComponent
import org.koin.core.component.get

actual class ImageDecoder : KoinComponent {
    actual suspend fun decode(source: ImageSource): PlatformImage {
        val context: Context = get()
        return BitmapFactory.decodeStream(
            context.contentResolver.openInputStream(source.build())
        ) ?: throw IllegalStateException("Failed to decode image from source")
    }
}
