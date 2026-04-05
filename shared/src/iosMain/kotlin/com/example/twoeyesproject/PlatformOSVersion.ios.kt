package com.example.twoeyesproject

import platform.UIKit.UIDevice

actual fun getPlatformOSVersion(): String {
    return UIDevice.currentDevice.systemVersion
}