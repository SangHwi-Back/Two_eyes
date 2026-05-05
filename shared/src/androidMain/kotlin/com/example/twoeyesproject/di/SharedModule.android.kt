package com.example.twoeyesproject.di

import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.getDatabaseBuilder
import com.example.twoeyesproject.dependency.getRoomDatabase
import com.example.twoeyesproject.image.ImageDecoder
import org.koin.android.ext.koin.androidContext
import org.koin.dsl.module

val sharedAndroidModule = module {
    factory { ImageDecoder() }
    single { getRoomDatabase(getDatabaseBuilder(androidContext())) }
    single { ApiClient() }
}
