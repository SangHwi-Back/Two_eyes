package com.example.twoeyesproject.platformspecific

import androidx.core.net.toUri

actual typealias ImageSource = android.net.Uri.Builder

actual fun String.toImageSource(): ImageSource? = this.toUri().buildUpon()