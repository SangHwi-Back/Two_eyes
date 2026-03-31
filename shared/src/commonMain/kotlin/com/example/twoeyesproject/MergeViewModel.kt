package com.example.twoeyesproject

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.CreationExtras
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.image.ImageFrame
import com.example.twoeyesproject.image.ImageSource
import com.example.twoeyesproject.image.PlatformImage
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.coroutineContext
import kotlin.reflect.KClass
import kotlin.time.Duration.Companion.milliseconds

@OptIn(FlowPreview::class)
class MergeViewModel(
    private val observer: Observer,
    private val source1: ImageSource,
    private val source2: ImageSource,
) : ViewModel() {
    private var imageViewZPositions = mutableListOf(ImageOrder.TOP, ImageOrder.BOTTOM)
    private var _mergeSubject = MutableSharedFlow<Unit>()
    val mergeSubject = _mergeSubject.asSharedFlow()
    private var _mergeTrigger = MutableSharedFlow<PlatformImage>()
    val mergeTrigger = _mergeTrigger.asSharedFlow()
    private var _targets = MutableSharedFlow<MutableList<CameraMergeTarget>>()
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