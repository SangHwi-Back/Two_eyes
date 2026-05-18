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
import kotlin.time.Clock

class PickImageMergeViewModel : ViewModel() {

    data class ImageState(
        val offsetX: Float = 0f,
        val offsetY: Float = 0f,
        val scale: Float = 1f,
        val filter: Filter? = null,
    ) {
        enum class Filter {
            INVERTED, // 반전
            VIGNETTE, // 삽화
            CONTRAST, // 대비
            SATURATION, // 채도
            MONOCHROME, // 흑백
        }
    }

    private val _leading = MutableStateFlow(ImageState())
    val leading = _leading.asStateFlow()

    private val _trailing = MutableStateFlow(ImageState())
    val trailing = _trailing.asStateFlow()

    // 첫 번째 원소가 아래(bottom) 레이어
    private val _zOrder = MutableStateFlow(listOf(ImageOrder.BOTTOM, ImageOrder.TOP))
    val zOrder = _zOrder.asStateFlow()

    fun updateLeading(offsetX: Float, offsetY: Float, scale: Float) {
        _leading.value = _leading.value.copy(offsetX = offsetX, offsetY = offsetY, scale = scale)
    }

    fun updateLeading(imageState: ImageState) {
        updateLeading(imageState.offsetX, imageState.offsetY, imageState.scale)
    }

    fun updateTrailing(offsetX: Float, offsetY: Float, scale: Float) {
        _trailing.value = _trailing.value.copy(offsetX = offsetX, offsetY = offsetY, scale = scale)
    }

    fun updateTrailing(imageState: ImageState) {
        updateTrailing(imageState.offsetX, imageState.offsetY, imageState.scale)
    }

    fun setLeadingFilter(filter: ImageState.Filter?) {
        _leading.value = _leading.value.copy(filter = filter)
    }

    fun setTrailingFilter(filter: ImageState.Filter?) {
        _trailing.value = _trailing.value.copy(filter = filter)
    }

    fun swapOrder() {
        val current = _zOrder.value.toMutableList()
        current.add(current.removeFirst())
        _zOrder.value = current
    }

    fun saveMergedImage(image: PlatformImage) {
    }

    fun saveMergedImage(
        dao: MergeResultDao,
        mergedImage: PlatformImage,
        leadingImageId: String,
        trailingImageId: String,
        name: String? = null
    ) {
        PlatformPersistImage().persistImage(mergedImage) {
            val entity = MergeResultEntity(
                resultId = it,
                leadingImageId = leadingImageId,
                trailingImageId = trailingImageId,
                name = name,
                date = Clock.System.now().toString(),
                isUploaded = false
            )
            viewModelScope.launch {
                dao.save(entity.copy(isUploaded = true))
            }
        }
    }

    enum class ImageOrder { TOP, BOTTOM }
}
