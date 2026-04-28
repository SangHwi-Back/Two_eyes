package com.example.twoeyesproject.image

import android.content.Context
import org.koin.core.component.KoinComponent
import org.koin.core.component.get
import androidx.core.net.toUri

actual class URIByteEncoder actual constructor(val uriString: String): KoinComponent {
    val context: Context = get()
    actual fun uriToByteArray(): ByteArray? {
        val uri = uriString.toUri()
        return context.contentResolver.openInputStream(uri)?.use {
            inputStream -> inputStream.readBytes()
        }
    }
}