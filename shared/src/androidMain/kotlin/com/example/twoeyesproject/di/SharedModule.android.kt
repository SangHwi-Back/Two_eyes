package com.example.twoeyesproject.di

import com.example.twoeyesproject.image.ImageDecoder
import org.koin.dsl.module

val sharedAndroidModule = module {
    factory { ImageDecoder() }
}
