package com.example.twoeyes.ui.camera

import android.content.ContentResolver
import android.content.ContentUris
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class CameraViewModel: ViewModel() {
    private val _items = MutableStateFlow<List<Any>>(emptyList())
    val items: StateFlow<List<Any>> = _items.asStateFlow()

    private val _selectedImages = MutableStateFlow<List<Any?>>(listOf(null, null))
    val selectedImages: StateFlow<List<Any?>> = _selectedImages.asStateFlow()

    fun addItem(item: Any) {
        _items.value = _items.value + item
    }

    fun selectImage(image: Any) {
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
}