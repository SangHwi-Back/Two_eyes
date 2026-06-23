package com.example.twoeyesproject.di

import com.example.twoeyesproject.dependency.getDatabaseBuilder
import com.example.twoeyesproject.dependency.getRoomDatabase
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.upload.UploadViewModel
import org.koin.android.ext.koin.androidContext
import org.koin.core.module.dsl.viewModel
import org.koin.dsl.module

/**
 * Android 전용 DI 모듈
 * 플랫폼별 의존성 (Room, ImageDecoder 등)을 정의
 */
val sharedAndroidModule = module {
    factory { ImageDecoder() }
    single { getRoomDatabase(getDatabaseBuilder(androidContext())) }

    // UploadViewModel은 AppDatabase가 필요 (Android 전용)
    viewModel { UploadViewModel(db = get()) }
}
