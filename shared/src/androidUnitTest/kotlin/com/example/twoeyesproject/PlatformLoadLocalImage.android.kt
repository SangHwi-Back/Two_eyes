package com.example.twoeyesproject

import android.graphics.BitmapFactory
import androidx.test.core.app.ApplicationProvider
import com.example.twoeyesproject.platformspecific.PlatformImage
import com.example.twoeyesproject.shared.R

actual fun getLennaImage(): PlatformImage {
    val context = ApplicationProvider.getApplicationContext<android.app.Application>()
    return BitmapFactory.decodeResource(context.resources, R.drawable.lenna)
}