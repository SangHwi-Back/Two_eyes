package com.example.twoeyesproject

import android.os.Build
import com.auth0.android.jwt.BuildConfig
import kotlinx.coroutines.flow.Flow

class AndroidPlatform : Platform {
    override val name: String = "Android ${Build.VERSION.SDK_INT}"
}

actual class CommonFlow<T> actual constructor(
    private val flow: Flow<T>
) : Flow<T> by flow

actual val isDebugBuild: Boolean
    get() = BuildConfig.DEBUG

actual fun getPlatform(): Platform = AndroidPlatform()