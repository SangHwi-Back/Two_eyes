package com.example.twoeyesproject

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.image.PlatformImage
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

    data class TargetModel(
        var leading: ImageViewModel,
        var trailing: ImageViewModel
    )
    data class ImageViewModel(
        val uuid: Uuid,
        var image: PlatformImage?,
        var isHighlighted: Boolean
    )

    fun setImage(image: PlatformImage) {
        val status = target.value

        when {
            status.leading.isHighlighted -> status.leading.image = image
            status.trailing.isHighlighted -> status.trailing.image = image
            status.leading.image == null -> status.leading.image = image
            status.trailing.image == null -> status.trailing.image = image
            else ->
                status.leading.image = image
        }

        _target.value = status
    }

    fun loadAllImages() {
        val fetcher = PickImageFetcher(this)
        viewModelScope.launch(Dispatchers.IO) {
            val images = fetcher.loadPlatformImages()
            _images.value = images
        }
    }

    fun highlightImageView(model: ImageViewModel) {
        if (target.value.leading.uuid == model.uuid) {
            target.value.leading.isHighlighted = target.value.leading.isHighlighted.not()
        } else if (target.value.trailing.uuid == model.uuid) {
            target.value.trailing.isHighlighted = target.value.trailing.isHighlighted.not()
        }
    }

    fun onImageCaptured(image: CapturedImage) {

    }
}

data class CapturedImage(
    val image: PlatformImage,
    val width: Int,
    val height: Int,
)