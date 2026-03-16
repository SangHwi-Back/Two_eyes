package com.example.twoeyes.ui

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.view.Gravity
import android.view.View
import android.widget.LinearLayout

class PageIndicatorView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs), IndexUpdateDelegate {
    init {
        orientation = HORIZONTAL
        gravity = Gravity.CENTER
    }

    override fun onUpdateIndex(index: Int) {
        for (i in 0 until childCount) {
            val dot = getChildAt(i)
            (dot.background as? GradientDrawable)?.setColor(
                if (i == index) Color.WHITE
                else Color.argb(100, 255, 255, 255)
            )
        }
    }

    fun setupDots(count: Int) {
        removeAllViews()
        if (count <= 1) return

        repeat(count) {
            val dot = View(context).apply {
                val size = 8.dp
                layoutParams = LayoutParams(size, size).apply { setMargins(4.dp, 0, 4.dp, 0) }
                background = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(Color.argb(100, 255, 255, 255))
                }
            }
            addView(dot)
        }
        onUpdateIndex(0)
    }

    private val Int.dp: Int
        get() = (this * resources.displayMetrics.density).toInt()
}