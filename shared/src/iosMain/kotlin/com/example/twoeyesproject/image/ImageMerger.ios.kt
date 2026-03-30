@file:OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)

package com.example.twoeyesproject.image

import platform.CoreGraphics.CGBlendMode
import platform.CoreGraphics.CGContextClipToRect
import platform.CoreGraphics.CGContextRestoreGState
import platform.CoreGraphics.CGContextSaveGState
import platform.CoreGraphics.CGRectIntersection
import platform.CoreGraphics.CGRectIsEmpty
import platform.CoreGraphics.CGRectIsNull
import platform.CoreGraphics.CGRectMake
import platform.CoreGraphics.CGSizeMake
import platform.UIKit.UIBezierPath
import platform.UIKit.UIGraphicsImageRenderer

actual class ImageMerger actual constructor() {
    actual fun merge(model: ImageMergerModel): PlatformImage {
        val size = CGSizeMake(model.canvasWidth.toDouble(), model.canvasHeight.toDouble())
        val renderer = UIGraphicsImageRenderer(size = size)

        return renderer.imageWithActions { context ->
            val cgContext = context?.CGContext
            val bottom = model.bottomImage
            val top = model.topImage

            bottom.image.drawInRect(bottom.frame.toCGRect())

            val intersection = CGRectIntersection(bottom.frame.toCGRect(), top.frame.toCGRect())

            if (CGRectIsNull(intersection) || CGRectIsEmpty(intersection)) {
                top.image.drawInRect(top.frame.toCGRect())
                return@imageWithActions
            }

            val clipPath = UIBezierPath.bezierPathWithRect(top.frame.toCGRect())
            clipPath.appendPath(UIBezierPath.bezierPathWithRect(intersection).bezierPathByReversingPath())
            clipPath.usesEvenOddFillRule = true

            CGContextSaveGState(cgContext)
            clipPath.addClip()
            top.image.drawInRect(top.frame.toCGRect())
            CGContextRestoreGState(cgContext)

            CGContextSaveGState(cgContext)
            CGContextClipToRect(cgContext, intersection)
            top.image.drawInRect(top.frame.toCGRect(), blendMode = CGBlendMode.kCGBlendModeNormal, alpha = model.blendAlpha.toDouble())
            CGContextRestoreGState(cgContext)
        }
    }

    private fun ImageFrame.toCGRect() = CGRectMake(
        left.toDouble(), top.toDouble(), (right - left).toDouble(), (bottom - top).toDouble()
    )
}