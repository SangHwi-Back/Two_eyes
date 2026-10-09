package com.example.twoeyesproject

import android.os.Build
import com.auth0.android.jwt.BuildConfig
import kotlinx.coroutines.flow.Flow

class AndroidPlatform : Platform {
    override val name: String = "Android ${Build.VERSION.SDK_INT}"
}

actual val isDebugBuild: Boolean
    get() = BuildConfig.DEBUG

actual fun getPlatform(): Platform = AndroidPlatform()