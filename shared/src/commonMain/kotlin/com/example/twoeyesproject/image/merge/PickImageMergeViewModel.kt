package com.example.twoeyesproject.image.merge

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.CreationExtras
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.image.ImageFrame
import com.example.twoeyesproject.image.ImageMerger
import com.example.twoeyesproject.image.ImageMergerModel
import com.example.twoeyesproject.platformspecific.ImageSource
import com.example.twoeyesproject.platformspecific.PlatformImage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.launch
import kotlin.reflect.KClass
import kotlin.time.Duration.Companion.milliseconds

@OptIn(FlowPreview::class)
class PickImageMergeViewModel(
    private val observer: Observer,
    private val source1: ImageSource,
    private val source2: ImageSource,
) : ViewModel() {
    private val merger = ImageMerger()
    private var imageViewZPositions = mutableListOf(ImageOrder.TOP, ImageOrder.BOTTOM)
    private val _mergeSubject = MutableStateFlow(Unit)
    val mergeSubject = _mergeSubject.asStateFlow()
    private val _mergeTrigger = MutableStateFlow<PlatformImage?>(null)
    val mergeTrigger = _mergeTrigger.asStateFlow()
    private val _targets = MutableStateFlow<MutableList<CameraMergeTarget>>(mutableListOf(
        CameraMergeTarget(ImageOrder.TOP,    ImageFrame(0f,   0f,   100f, 100f)),
        CameraMergeTarget(ImageOrder.BOTTOM, ImageFrame(100f, 100f, 200f, 200f))
    ))
    val targets = _targets.asStateFlow()

    // 이미지는 합성 연산에만 사용 — 뷰에 노출하지 않음
    private val images = mutableMapOf<ImageOrder, PlatformImage>()

    init {
        viewModelScope.launch {
            val decoder = ImageDecoder()
            images[ImageOrder.TOP] = decoder.decode(source1)
            images[ImageOrder.BOTTOM] = decoder.decode(source2)

            _mergeTrigger
                .debounce(16.milliseconds)
                .collect { triggerMerge() }
        }
    }

    fun updatePosition(order: ImageOrder, x: Float, y: Float) {
        val values = _targets.value
        var index = 0
        when (order) {
            ImageOrder.TOP -> {
                values[0].rect.setPosition(x, y)
                index = 0
            }
            ImageOrder.BOTTOM -> {
                values[1].rect.setPosition(x, y)
                index = 1
            }
        }
        val image = images[values[index].order] ?: return
        observer.didStatusChanged(CameraMergeEffect.OnStatusChanged(image))
        setNewTargetState(values)
    }

    fun swapOrder() {
        imageViewZPositions.add(imageViewZPositions.removeFirst())
        observer.didSwapedZPosition(
            CameraMergeEffect.OnSwapZPosition(imageViewZPositions.toList()))
        setNewTargetState(_targets.value.asReversed())
    }

    private fun setNewTargetState(list: MutableList<CameraMergeTarget>) {
        viewModelScope.launch {
            _targets.value = list
            triggerMerge()
        }
    }

    private fun triggerMerge() {
        viewModelScope.launch(Dispatchers.Default) {
            val values = _targets.value
            if (values.size < 2) return@launch

            val model = ImageMergerModel(
                canvasWidth = 300,
                canvasHeight = 700,
                ImageMergerModel.ImageInfo(images[values[1].order] ?: return@launch, values[1].rect),
                ImageMergerModel.ImageInfo(images[values[0].order] ?: return@launch, values[0].rect),
            )

            val merged = merger.merge(model)
            _mergeTrigger.emit(merged)
        }
    }

    interface Observer {
        fun didSwapedZPosition(effect: CameraMergeEffect.OnSwapZPosition)
        fun didStatusChanged(effect: CameraMergeEffect.OnStatusChanged)
    }
    enum class ImageOrder { TOP, BOTTOM }
    sealed class CameraMergeEffect {
        data class OnSwapZPosition(val order: List<ImageOrder>)
        data class OnStatusChanged(val image: PlatformImage)
    }

    // image 필드 제거 — 이미지는 ViewModel 내부 images 맵에서 관리
    data class CameraMergeTarget(
        val order: ImageOrder,
        val rect: ImageFrame
    )
}

class MergeViewModelFactory(
    private val observer: PickImageMergeViewModel.Observer,
    private val source1: ImageSource,
    private val source2: ImageSource,
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: KClass<T>, extras: CreationExtras): T {
        if (modelClass.isInstance(PickImageMergeViewModel::class))
            throw IllegalArgumentException("Unknown ViewModel Class")
        @Suppress("UNCHECKED_CAST")
        return PickImageMergeViewModel(observer, source1, source2) as T
    }
}
