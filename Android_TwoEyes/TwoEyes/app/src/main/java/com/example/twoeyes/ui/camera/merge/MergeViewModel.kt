package com.example.twoeyes.ui.camera.merge

import android.graphics.Bitmap
import android.graphics.PointF
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyes.ImageMerger
import com.example.twoeyes.MergeTarget
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.launch

class MergeViewModel(
    private var _targets: List<Target>
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
            val result = merger.merge(targets[0].toMergeTarget(), targets[1].toMergeTarget())
            mergeTrigger.tryEmit(result)
        }
    }
}

data class Target(
    val order: Order,
    val bitmap: Bitmap,
    val position: PointF,
) {
    enum class Order { Top, Bottom }
}

fun Target.toMergeTarget(): MergeTarget = MergeTarget(bitmap, position)