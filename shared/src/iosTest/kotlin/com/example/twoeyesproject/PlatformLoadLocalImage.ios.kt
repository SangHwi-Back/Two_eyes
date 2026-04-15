package com.example.twoeyesproject

import com.example.twoeyesproject.platformspecific.PlatformImage
import kotlinx.cinterop.BetaInteropApi
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.ObjCClass
import platform.Foundation.NSBundle
import platform.UIKit.UIImage

@OptIn(ExperimentalForeignApi::class, BetaInteropApi::class)
actual fun getLennaImage(): PlatformImage {
    val bundle = NSBundle.bundleForClass(UIImage::class as ObjCClass)
    val image = bundle.pathForResource("lenna", "jpeg")?.let {
        UIImage.imageWithContentsOfFile(it)
    }
    return image ?: throw Exception("")
}