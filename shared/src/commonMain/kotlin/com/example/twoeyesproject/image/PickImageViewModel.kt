package com.example.twoeyesproject.image

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.platformspecific.ImageSource
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
    private var _imageSources = MutableStateFlow<List<ImageSource>>(listOf())
    val imageSources: StateFlow<List<ImageSource>> = _imageSources.asStateFlow()

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

    suspend fun setImageFromSource(imageSource: ImageSource) {
        val status = target.value
        val image = ImageDecoder().decode(imageSource)

        if (target.value.leading.isHighlighted) {
            _target.value = target.value.copy(leading = status.leading.copy(image = image))
        }

        if (target.value.trailing.isHighlighted) {
            _target.value = target.value.copy(trailing = status.leading.copy(image = image))
        }
    }

    fun deleteImage(model: ImageViewModel) {
        val status = target.value

        val newStatus = when (model.uuid) {
            target.value.leading.uuid -> target.value.copy(leading = status.leading.copy(image = null))
            target.value.trailing.uuid -> target.value.copy(trailing = status.trailing.copy(image = null))
            else -> status
        }

        _target.value = newStatus
    }

    fun loadAllImages() {
        val fetcher = PickImageFetcher(this)

        viewModelScope.launch(Dispatchers.IO) {
            val sources = fetcher.loadPlatformSourceOfImages()
            _imageSources.value = sources
        }
    }

    fun highlightImageView(model: ImageViewModel) {
        val status = target.value

        val newStatus = when (model.uuid) {
            status.leading.uuid -> status.copy(
                leading = status.leading.copy(isHighlighted = !status.leading.isHighlighted),
                trailing = status.trailing.copy(isHighlighted = false))
            status.trailing.uuid -> status.copy(
                leading = status.leading.copy(isHighlighted = false),
                trailing = status.trailing.copy(isHighlighted = !status.trailing.isHighlighted))
            else -> status
        }

        _target.value = newStatus
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