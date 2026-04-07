package com.example.twoeyesproject.platformspecific

import android.net.Uri
import androidx.core.net.toUri

actual class PlatformUri(val uri: Uri)

actual fun parseUri(string: String): PlatformUri = PlatformUri(string.toUri())