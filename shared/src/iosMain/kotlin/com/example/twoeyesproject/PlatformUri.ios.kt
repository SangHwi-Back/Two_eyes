package com.example.twoeyesproject

import platform.Foundation.NSURL

actual class PlatformUri(val url: NSURL)

actual fun parseUri(string: String): PlatformUri = PlatformUri(NSURL.URLWithString(string)!!)