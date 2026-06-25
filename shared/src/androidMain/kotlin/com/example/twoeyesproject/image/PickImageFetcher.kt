package com.example.twoeyesproject.image

import android.content.ContentUris
import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import com.example.twoeyesproject.platformspecific.ImageSource
import com.example.twoeyesproject.platformspecific.PlatformImage
import kotlinx.coroutines.suspendCancellableCoroutine
import org.koin.core.component.KoinComponent
import org.koin.core.component.get
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

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

    actual suspend fun loadImageUsingSource(source: ImageSource): PlatformImage? =
        suspendCancellableCoroutine { continuation ->
            var connection: HttpURLConnection? = null
            var inputStream: InputStream? = null
            try {
                val url = URL(source.toString())
                connection = url.openConnection() as HttpURLConnection
                connection.doInput = true
                connection.connect()

                inputStream = connection.inputStream
                // Decode the stream into a usable Bitmap object
                continuation.resume(BitmapFactory.decodeStream(inputStream))
            } catch (e: Exception) {
                e.printStackTrace()
                continuation.resumeWithException(e)
            } finally {
                // Always clean up your streams and connections
                inputStream?.close()
                connection?.disconnect()
            }
        }
}