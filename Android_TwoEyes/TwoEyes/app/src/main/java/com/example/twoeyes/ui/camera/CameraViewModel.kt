package com.example.twoeyes.ui.camera

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.material.imageview.ShapeableImageView
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.io.File

class CameraViewModel: ViewModel() {
    private val _items = MutableStateFlow<List<Uri>>(emptyList())
    val items: StateFlow<List<Uri>> = _items.asStateFlow()

    private val _selectedImages = MutableStateFlow<List<Uri?>>(listOf(null, null))
    val selectedImages: StateFlow<List<Uri?>> = _selectedImages.asStateFlow()
    private var _highlightedImageView = MutableStateFlow<ShapeableImageView?>(null)
    val highlightedImageView: StateFlow<ShapeableImageView?> = _highlightedImageView.asStateFlow()

    fun addItem(item: Uri) {
        _items.value = _items.value + item
    }

    fun selectImage(image: Uri) {
        val current = _selectedImages.value.toMutableList()
        when {
            current[0] == null -> current[0] = image
            current[1] == null -> current[1] = image
            else -> current[0] = image
        }
        _selectedImages.value = current
    }
    fun loadAllImages(contentResolver: ContentResolver) {
        viewModelScope.launch(Dispatchers.IO) {
            val uris = mutableListOf<Uri>()
            val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
                MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            else
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            val projection = arrayOf(MediaStore.Images.Media._ID)
            val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

            contentResolver.query(collection, projection, null, null, sortOrder)?.use { cursor ->
                val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
                while (cursor.moveToNext()) {
                    val id = cursor.getLong(idColumn)
                    val uri = ContentUris.withAppendedId(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                    uris.add(uri)
                }
            }
            _items.value = uris
        }
    }
    fun copyToAppStorage(context: Context, sourceUri: Uri) {
        viewModelScope.launch(Dispatchers.IO) {
            val destFile = File(
                context.getExternalFilesDir(Environment.DIRECTORY_PICTURES),
                "gallery_${System.currentTimeMillis()}.jpg"
            )
            context.contentResolver.openInputStream(sourceUri)?.use { inputStream ->
                destFile.outputStream().use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            }
            val destUri = Uri.fromFile(destFile)
            _items.value = _items.value + destUri
        }
    }

    fun highlightImageView(imageView: ShapeableImageView): ShapeableImageView {
        val prev = _highlightedImageView.value
        _highlightedImageView.value = if (imageView == prev) null else imageView
        return imageView
    }
}