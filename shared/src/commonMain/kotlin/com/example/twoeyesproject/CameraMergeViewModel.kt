package com.example.twoeyesproject

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.image.ImageFrame
import com.example.twoeyesproject.image.PlatformImage
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.launch
import kotlin.time.Duration.Companion.milliseconds

@OptIn(FlowPreview::class)
class CameraMergeViewModel(
    private val observer: Observer,
    private var _targets: List<CameraMergeTarget>,
    private val canvasWidth: Float,
    private val canvasHeight: Float,
) : ViewModel() {
    private var imageViewZPositions = mutableListOf(ImageOrder.TOP, ImageOrder.BOTTOM)
    private var _mergeSubject = MutableSharedFlow<Unit>()
    val mergeSubject = _mergeSubject.asSharedFlow()
    private var _mergeTrigger = MutableSharedFlow<PlatformImage>()
    val mergeTrigger = _mergeTrigger.asSharedFlow()

    init {
        viewModelScope.launch {
            _mergeTrigger
                .debounce(16.milliseconds)
                .collect { triggerMerge() }
        }
    }

    private fun triggerMerge() {
        TODO("Not yet implemented")
    }

    fun swapZPosition() {
        imageViewZPositions.add(imageViewZPositions.removeFirst())
        observer.didSwapedZPosition(CameraMergeEffect.OnSwapZPosition(imageViewZPositions.toList()))
        _mergeSubject.tryEmit(Unit)
    }
    interface Observer {
        fun didCallInitialStatus(effect: CameraMergeEffect.OnCallInitialStatus)
        fun didSwapedZPosition(effect: CameraMergeEffect.OnSwapZPosition)
        fun didStatusChanged(effect: CameraMergeEffect.OnStatusChanged)
    }
    enum class ImageOrder { TOP, BOTTOM }
    sealed class CameraMergeEffect {
        data class OnCallInitialStatus(val status: List<CameraImageViewStatus>)
        data class OnSwapZPosition(val order: List<ImageOrder>)
        data class OnStatusChanged(val image: PlatformImage)
    }
    data class CameraMergeTarget(
        val order: ImageOrder,
        val image: PlatformImage,
        val rect: ImageFrame
    )
}

data class CameraImageViewStatus(
    var image: PlatformImage,
    var frame: ImageFrame
)

class MergeViewModelFactory(

)