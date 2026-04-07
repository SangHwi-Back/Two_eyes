package com.example.twoeyesproject.platformspecific

import platform.UIKit.UIDevice

actual fun getPlatformOSVersion(): String {
    return UIDevice.Companion.currentDevice.systemVersion
}