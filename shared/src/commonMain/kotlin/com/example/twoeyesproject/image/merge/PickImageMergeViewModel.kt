package com.example.twoeyesproject.image.merge

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.dependency.MergeResultDao
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.platformspecific.PlatformImage
import com.example.twoeyesproject.platformspecific.PlatformPersistImage
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class PickImageMergeViewModel : ViewModel() {

    data class ImageState(
        val offsetX: Float = 0f,
        val offsetY: Float = 0f,
        val scale: Float = 1f
    )

    private val _leading = MutableStateFlow(ImageState())
    val leading = _leading.asStateFlow()

    private val _trailing = MutableStateFlow(ImageState())
    val trailing = _trailing.asStateFlow()

    // 첫 번째 원소가 아래(bottom) 레이어
    private val _zOrder = MutableStateFlow(listOf(ImageOrder.BOTTOM, ImageOrder.TOP))
    val zOrder = _zOrder.asStateFlow()

    fun updateLeading(offsetX: Float, offsetY: Float, scale: Float) {
        _leading.value = ImageState(offsetX, offsetY, scale)
    }

    fun updateLeading(imageState: ImageState) {
        updateLeading(imageState.offsetX, imageState.offsetY, imageState.scale)
    }

    fun updateTrailing(offsetX: Float, offsetY: Float, scale: Float) {
        _trailing.value = ImageState(offsetX, offsetY, scale)
    }

    fun updateTrailing(imageState: ImageState) {
        updateTrailing(imageState.offsetX, imageState.offsetY, imageState.scale)
    }

    fun swapOrder() {
        val current = _zOrder.value.toMutableList()
        current.add(current.removeFirst())
        _zOrder.value = current
    }

    fun saveMergedImage(image: PlatformImage) {
        PlatformPersistImage().persistImage(image)
    }

    fun uploadEntity(dao: MergeResultDao, entity: MergeResultEntity) {
        viewModelScope.launch {
            dao.save(entity.copy(isUploaded = true))
        }
    }

    enum class ImageOrder { TOP, BOTTOM }
}
