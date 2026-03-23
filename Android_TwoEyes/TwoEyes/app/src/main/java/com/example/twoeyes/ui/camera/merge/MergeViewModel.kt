package com.example.twoeyes.ui.camera.merge

import android.graphics.Bitmap
import android.graphics.PointF
import android.graphics.RectF
import android.util.SizeF
import androidx.lifecycle.ViewModel
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