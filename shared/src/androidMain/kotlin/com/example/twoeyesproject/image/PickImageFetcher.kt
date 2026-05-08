package com.example.twoeyesproject.image

import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import com.example.twoeyesproject.platformspecific.ImageSource
import org.koin.core.component.KoinComponent
import org.koin.core.component.get

@RequiresApi(Build.VERSION_CODES.O)
actual class PickImageFetcher: KoinComponent {
    val context: Context = get()
    private val collection: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
        MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
    else
        MediaStore.Images.Media.EXTERNAL_CONTENT_URI
    private val projection = arrayOf(MediaStore.Images.Media._ID)
    private val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

    actual suspend fun loadPlatformSourceOfImages(): List<ImageSource> {
        val sources = mutableListOf<ImageSource>()

        context.contentResolver.query(collection, projection, null, null, sortOrder)?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)
                val contentUri = ContentUris.withAppendedId(collection, id)
                sources.add(contentUri.buildUpon())
            }
        }

        return sources.toList()
    }
}