package com.example.twoeyesproject.platformspecific

import android.os.Build

actual fun getPlatformOSVersion(): String = Build.VERSION.SDK_INT.toString()