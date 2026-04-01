package com.example.twoeyesproject

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.CreationExtras
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.image.ImageFrame
import com.example.twoeyesproject.image.ImageMerger
import com.example.twoeyesproject.image.ImageMergerModel
import com.example.twoeyesproject.image.ImageSource
import com.example.twoeyesproject.image.PlatformImage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlin.contracts.Effect
import kotlin.reflect.KClass
import kotlin.time.Duration.Companion.milliseconds

@OptIn(FlowPreview::class)
class MergeViewModel(
    private val observer: Observer,
    private val source1: ImageSource,
    private val source2: ImageSource,
) : ViewModel() {
    private val merger = ImageMerger()
    private var imageViewZPositions = mutableListOf(ImageOrder.TOP, ImageOrder.BOTTOM)
    private var _mergeSubject = MutableSharedFlow<Unit>()
    val mergeSubject = _mergeSubject.asSharedFlow()
    private var _mergeTrigger = MutableSharedFlow<PlatformImage>()
    val mergeTrigger = _mergeTrigger.asSharedFlow()
    private var _targets = MutableStateFlow<MutableList<CameraMergeTarget>>(mutableListOf())
    val targets = _targets.asSharedFlow()

    init {
        viewModelScope.launch {
            val decoder = ImageDecoder()
            val image1 = decoder.decode(source1)
            val image2 = decoder.decode(source2)

            _targets.emit(mutableListOf(
                CameraMergeTarget(ImageOrder.TOP, image1, ImageFrame(0f,0f,100f,100f)),
                CameraMergeTarget(ImageOrder.BOTTOM, image2, ImageFrame(100f,100f,200f,200f))
            ))

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

        observer.didStatusChanged(
            CameraMergeEffect.OnStatusChanged(values[index].image))
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

            if (values.size < 2) {
                return@launch
            }

            val model = ImageMergerModel(
                canvasWidth = 300,
                canvasHeight = 700,
                values[1].toImageInfo(),
                values[0].toImageInfo(),
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
    data class CameraMergeTarget(
        val order: ImageOrder,
        val image: PlatformImage,
        val rect: ImageFrame
    )

    fun CameraMergeTarget.toImageInfo(): ImageMergerModel.ImageInfo =
        ImageMergerModel.ImageInfo(image, rect)

}

data class CameraImageViewStatus(
    var image: PlatformImage,
    var frame: ImageFrame
)

class MergeViewModelFactory(
    private val observer: MergeViewModel.Observer,
    private val source1: ImageSource,
    private val source2: ImageSource,
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: KClass<T>, extras: CreationExtras): T {
        if (modelClass.isInstance(MergeViewModel::class))
            throw IllegalArgumentException("Unknown ViewModel Class")
        @Suppress("UNCHECKED_CAST")
        return MergeViewModel(observer, source1, source2) as T
    }
}