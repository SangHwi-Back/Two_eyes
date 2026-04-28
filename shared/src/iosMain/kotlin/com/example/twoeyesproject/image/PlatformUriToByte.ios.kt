package com.example.twoeyesproject.image

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.addressOf
import kotlinx.cinterop.usePinned
import platform.Foundation.NSData
import platform.Foundation.NSURL
import platform.Foundation.dataWithContentsOfURL
import platform.posix.memcpy

actual class URIByteEncoder actual constructor(val uriString: String) {
    actual fun uriToByteArray(): ByteArray? {
        val url = NSURL.URLWithString(uriString) ?: return null
        val data = NSData.dataWithContentsOfURL(url) ?: return null
        return data.toByteArray()
    }
}

@OptIn(ExperimentalForeignApi::class)
fun NSData.toByteArray(): ByteArray {
    val size = length.toInt()
    return ByteArray(size).apply {
        if (size > 0) {
            usePinned { pinned ->
                memcpy(pinned.addressOf(0), bytes, length)
            }
        }
    }
}