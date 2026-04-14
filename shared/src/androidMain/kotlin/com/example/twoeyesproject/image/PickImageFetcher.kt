package com.example.twoeyesproject.image

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import androidx.core.net.toUri
import com.example.twoeyesproject.platformspecific.ImageSource
import com.example.twoeyesproject.platformspecific.PlatformImage
import org.koin.core.component.KoinComponent
import org.koin.core.component.get

@RequiresApi(Build.VERSION_CODES.O)
actual class PickImageFetcher actual constructor(val viewModel: PickImageViewModel): KoinComponent {
    val context: Context = get()
    private val collection: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
        MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
    else
        MediaStore.Images.Media.EXTERNAL_CONTENT_URI
    private val projection = arrayOf(MediaStore.Images.Media._ID)
    private val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

    actual suspend fun loadPlatformSourceOfImages(): List<ImageSource> {
        val bitmaps = mutableListOf<ImageSource>()

        context.contentResolver.query(collection, projection, null, null, sortOrder)?.use { cursor ->
            while (cursor.moveToNext()) {
                // 1. Get the path from the DATA column
                val columnIndex = cursor.getColumnIndex(
                    MediaStore.Images.Media.DATA)
                // 2. Decode the file path into a Bitmap
                bitmaps.add(cursor.getString(columnIndex)
                    .toUri().buildUpon())
            }
        }

        return bitmaps.toList()
    }
}