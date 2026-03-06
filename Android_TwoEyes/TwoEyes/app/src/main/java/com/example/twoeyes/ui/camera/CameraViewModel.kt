package com.example.twoeyes.ui.camera

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class CameraViewModel: ViewModel() {
    private val _items = MutableStateFlow<List<Any>>(emptyList())
    val items: StateFlow<List<Any>> = _items.asStateFlow()

    fun addItem(item: Any) {
        _items.value = _items.value + item
    }
}