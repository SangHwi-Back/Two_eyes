package com.example.twoeyesproject

import android.os.Build

actual fun getPlatformOSVersion(): String = Build.VERSION.SDK_INT.toString()