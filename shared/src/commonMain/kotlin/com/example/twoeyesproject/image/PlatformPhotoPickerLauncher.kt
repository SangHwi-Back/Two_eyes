package com.example.twoeyesproject.image

import com.example.twoeyesproject.platformspecific.ImageSource

interface PhotoPickerLauncher {
    fun launch()
}

interface PickerImageSourceDelegate {
    fun addImageSource(imageSource: ImageSource)
    fun addImageSources(sources: List<ImageSource>)
}