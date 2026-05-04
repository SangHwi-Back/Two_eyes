package com.example.twoeyesproject.platformspecific

expect class ImageSource

expect fun String.toImageSource(): ImageSource?

expect fun ImageSource.convertToString(): String