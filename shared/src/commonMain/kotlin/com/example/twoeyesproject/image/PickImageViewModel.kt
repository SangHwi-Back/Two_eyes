package com.example.twoeyesproject.image

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.platformspecific.PlatformImage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlin.uuid.ExperimentalUuidApi
import kotlin.uuid.Uuid

@OptIn(ExperimentalUuidApi::class)
class PickImageViewModel: ViewModel() {
    private var _target = MutableStateFlow<TargetModel>(TargetModel(
        ImageViewModel(Uuid.random(), null, false),
        ImageViewModel(Uuid.random(), null, false),
    ))
    val target: StateFlow<TargetModel> = _target.asStateFlow()
    private var _capturedImage = MutableStateFlow<CapturedImage?>(null)
    val capturedImage: StateFlow<CapturedImage?> = _capturedImage.asStateFlow()
    private var _images = MutableStateFlow<List<PlatformImage>>(listOf())
    val images: StateFlow<List<PlatformImage>> = _images.asStateFlow()

    var onImagesUpdated: ((List<PlatformImage>) -> Unit)? = null
        set(value) {
            field = value
            onImagesUpdated?.invoke(images.value)
        }
    var onImageCaptured: ((CapturedImage) -> Unit)? = null
        set(value) {
            field = value
            capturedImage.value?.let { onImageCaptured?.invoke(it) }
        }

    data class TargetModel(
        val leading: ImageViewModel,
        val trailing: ImageViewModel
    )
    data class ImageViewModel(
        val uuid: Uuid,
        val image: PlatformImage?,
        val isHighlighted: Boolean
    )

    fun setImage(image: PlatformImage) {
        val status = target.value

        if (target.value.leading.isHighlighted) {
            _target.value = target.value.copy(leading = status.leading.copy(image = image))
        }

        if (target.value.trailing.isHighlighted) {
            _target.value = target.value.copy(trailing = status.leading.copy(image = image))
        }
    }

    fun loadAllImages() {
        val fetcher = PickImageFetcher(this)
        viewModelScope.launch(Dispatchers.IO) {
            val images = fetcher.loadPlatformImages()
            _images.value = images
        }
    }

    fun highlightImageView(model: ImageViewModel) {
        val status = target.value
        _target.value = when (model.uuid) {
            status.leading.uuid -> status.copy(leading = status.leading.copy(isHighlighted = status.leading.isHighlighted.not()))
            status.trailing.uuid -> status.copy(trailing = status.trailing.copy(isHighlighted = status.trailing.isHighlighted.not()))
            else -> status
        }
    }

    fun setCapturedImage(capturedImage: CapturedImage) {
        _capturedImage.value = capturedImage
        _images.value += capturedImage.image

        val status = target.value
        _target.value = when {
            status.leading.isHighlighted -> status.copy(leading = status.leading.copy(image = capturedImage.image))
            status.trailing.isHighlighted -> status.copy(trailing = status.trailing.copy(image = capturedImage.image))
            else -> status
        }
    }
}

data class CapturedImage(
    val image: PlatformImage,
    val width: Int,
    val height: Int,
)