package com.example.twoeyesproject.image

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.platformspecific.ImageSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlin.uuid.ExperimentalUuidApi
import kotlin.uuid.Uuid

@OptIn(ExperimentalUuidApi::class)
class PickImageViewModel: ViewModel(), PickerImageSourceDelegate {
    private val _target = MutableStateFlow<TargetModel>(TargetModel(
        ImageViewModel(Uuid.random(), null, false),
        ImageViewModel(Uuid.random(), null, false),
    ))
    val target: StateFlow<TargetModel> = _target.asStateFlow()

    private val _imageSources = MutableStateFlow<List<ImageSource>>(listOf())
    val imageSources: StateFlow<List<ImageSource>> = _imageSources.asStateFlow()

    // GetAll 버튼으로 갤러리를 로드한 적이 있는지 추적
    private val _isGalleryLoaded = MutableStateFlow(false)
    val isGalleryLoaded: StateFlow<Boolean> = _isGalleryLoaded.asStateFlow()

    data class TargetModel(
        val leading: ImageViewModel,
        val trailing: ImageViewModel
    )
    data class ImageViewModel(
        val uuid: Uuid,
        val imageSource: ImageSource?,
        val isHighlighted: Boolean
    )

    /** 썸네일 리스트에서 선택 — 하이라이트된 슬롯에 이미지 지정 + 리스트에 추가 */
    fun setImageFromSource(imageSource: ImageSource) {
        val status = target.value

        if (status.leading.isHighlighted) {
            _target.value = target.value.copy(leading = status.leading.copy(imageSource = imageSource))
        }

        if (status.trailing.isHighlighted) {
            _target.value = target.value.copy(trailing = status.trailing.copy(imageSource = imageSource))
        }

        if (!imageSources.value.contains(imageSource)) {
            _imageSources.value += imageSource
        }
    }

    /** 카메라 촬영 후 슬롯에만 지정 — 리스트에는 추가하지 않음 */
    fun setCameraImage(imageSource: ImageSource) {
        val status = target.value
        _target.value = when {
            status.leading.isHighlighted  -> status.copy(leading  = status.leading.copy(imageSource  = imageSource))
            status.trailing.isHighlighted -> status.copy(trailing = status.trailing.copy(imageSource = imageSource))
            else -> status
        }
    }

    fun deleteImage(model: ImageViewModel) {
        val status = target.value
        _target.value = when (model.uuid) {
            status.leading.uuid  -> target.value.copy(leading  = status.leading.copy(imageSource  = null))
            status.trailing.uuid -> target.value.copy(trailing = status.trailing.copy(imageSource = null))
            else -> status
        }
    }

    /** GetAll — 전체 갤러리 로드. 이후 카메라 이미지도 리스트에 추가됨 */
    fun loadAllImages() {
        _isGalleryLoaded.value = true
        val fetcher = PickImageFetcher()
        viewModelScope.launch(Dispatchers.IO) {
            val sources = fetcher.loadPlatformSourceOfImages()
            _imageSources.value = sources
        }
    }

    fun highlightImageView(model: ImageViewModel) {
        val status = target.value
        _target.value = when (model.uuid) {
            status.leading.uuid -> status.copy(
                leading  = status.leading.copy(isHighlighted  = !status.leading.isHighlighted),
                trailing = status.trailing.copy(isHighlighted = false))
            status.trailing.uuid -> status.copy(
                leading  = status.leading.copy(isHighlighted  = false),
                trailing = status.trailing.copy(isHighlighted = !status.trailing.isHighlighted))
            else -> status
        }
    }

    override fun addImageSource(imageSource: ImageSource) {
        if (!imageSources.value.contains(imageSource)) {
            _imageSources.value += imageSource
        }
    }

    override fun addImageSources(sources: List<ImageSource>) {
        _imageSources.value = sources
    }
}
