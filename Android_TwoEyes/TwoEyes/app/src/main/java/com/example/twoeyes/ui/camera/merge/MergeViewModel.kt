package com.example.twoeyes.ui.camera.merge

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.PointF
import android.graphics.RectF
import android.net.Uri
import android.util.SizeF
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.twoeyes.ImageMerger
import com.example.twoeyes.ImageMergerModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.launch

class MergeViewModel(
    private var _targets: List<Target>,
    private val canvasSize: SizeF
) : ViewModel() {
    private val merger = ImageMerger()
    val targets = _targets
    val mergeTrigger = MutableSharedFlow<Bitmap>(extraBufferCapacity = 1)
    val switchOrderResult = MutableStateFlow(Unit)

    init {
        viewModelScope.launch {
            mergeTrigger
                .debounce(16L)
                .collect { triggerMerge() }
        }
    }

    fun updatePosition(order: Target.Order, x: Float, y: Float) {
        when (order) {
            Target.Order.Top -> targets[0].position.set(x, y)
            Target.Order.Bottom -> targets[1].position.set(x, y)
        }
        triggerMerge()
    }

    fun swapOrder() {
        viewModelScope.launch {
            _targets = targets.reversed()
            switchOrderResult.emit(Unit)
            triggerMerge()
        }
    }

    private fun triggerMerge() {
        viewModelScope.launch(Dispatchers.Default) {
            val b1 = targets[0].bitmap
            val b2 = targets[1].bitmap

            val frame1 = RectF(
                targets[0].position.x - targets[0].size.width / 2f,
                targets[0].position.y - targets[0].size.height / 2f,
                targets[0].position.x + targets[0].size.width / 2f,
                targets[0].position.y + targets[0].size.height / 2f
            )
            val frame2 = RectF(
                targets[1].position.x - targets[1].size.width / 2f,
                targets[1].position.y - targets[1].size.height / 2f,
                targets[1].position.x + targets[1].size.width / 2f,
                targets[1].position.y + targets[1].size.height / 2f
            )

            val topInfo = ImageMergerModel.BitmapInfo(b1, frame1)
            val bottomInfo = ImageMergerModel.BitmapInfo(b2, frame2)

            val model = ImageMergerModel(
                canvasWidth = canvasSize.width.toInt(),
                canvasHeight = canvasSize.height.toInt(),
                bottomBitmap = bottomInfo,
                topBitmap = topInfo
            )

            val merged = merger.merge(model)
            mergeTrigger.tryEmit(merged)
        }
    }
}

data class Target(
    val order: Order,
    val bitmap: Bitmap,
    val position: PointF,
    val size: SizeF
) {
    enum class Order { Top, Bottom }
}

// MergeViewModel.kt 하단에 추가
class MergeViewModelFactory(
    private val context: Context,
    private val uri1: String,
    private val uri2: String,
    private val canvasSize: SizeF
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (!modelClass.isAssignableFrom(MergeViewModel::class.java))
            throw IllegalArgumentException("Unknown ViewModel class")

        val bitmap1 = BitmapFactory.decodeStream(
            context.contentResolver.openInputStream(Uri.parse(uri1))
        )
        val bitmap2 = BitmapFactory.decodeStream(
            context.contentResolver.openInputStream(Uri.parse(uri2))
        )

        val targets = listOf(
            Target(Target.Order.Top,    bitmap1, PointF(), SizeF(canvasSize.width / 2, canvasSize.height / 2)),
            Target(Target.Order.Bottom, bitmap2, PointF(), SizeF(canvasSize.width / 2, canvasSize.height / 2))
        )

        @Suppress("UNCHECKED_CAST")
        return MergeViewModel(targets, canvasSize) as T
    }
}
