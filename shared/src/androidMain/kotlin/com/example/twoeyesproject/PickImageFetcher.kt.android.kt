package com.example.twoeyesproject

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import com.example.twoeyesproject.image.PlatformImage
import org.koin.core.component.KoinComponent
import org.koin.core.component.get


@RequiresApi(Build.VERSION_CODES.O)
actual class PickImageFetcher actual constructor(val viewModel: PickImageViewModel): KoinComponent {
    val context: Context = get()
    actual suspend fun loadPlatformImages(): List<PlatformImage> {
        val bitmaps = mutableListOf<Bitmap>()
        val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
        else
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(MediaStore.Images.Media._ID)
        val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

        context.contentResolver.query(collection, projection, null, null, sortOrder)?.use { cursor ->
            while (cursor.moveToNext()) {
                // 1. Get the path from the DATA column
                val columnIndex = cursor.getColumnIndex(MediaStore.Images.Media.DATA)
                val filePath = cursor.getString(columnIndex)
                // 2. Decode the file path into a Bitmap
                val bitmap = BitmapFactory.decodeFile(filePath)
                bitmaps.add(bitmap)
            }
        }

        return bitmaps.toList()
    }
}