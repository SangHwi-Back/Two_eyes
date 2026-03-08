package com.example.twoeyes.ui.camera

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

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
}