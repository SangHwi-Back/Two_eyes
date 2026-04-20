package com.example.twoeyesproject.platformspecific

import android.content.ContentValues
import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.provider.MediaStore
import org.koin.core.component.KoinComponent
import org.koin.core.component.get

actual class PlatformPersistImage: KoinComponent {
    actual fun persistImage(image: PlatformImage) {
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, "ImageName.jpg")
            put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
            // Use RELATIVE_PATH to create or specify the album name
            put(MediaStore.MediaColumns.RELATIVE_PATH, "Pictures/MyCustomAlbum")
        }
        val context: Context = get()
        val uri: Uri? = context.contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)

        uri?.let {
            context.contentResolver.openOutputStream(it).use { stream ->
                if (stream != null)
                    image.compress(Bitmap.CompressFormat.JPEG, 100, stream)
            }
        }
    }
}