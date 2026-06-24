package com.example.twoeyesproject.di

import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.getAppDatabase
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.upload.UploadViewModel
import org.koin.dsl.module

/**
 * iOS 전용 DI 모듈
 * 플랫폼별 의존성 (Room 등)을 정의
 */
val sharedIosModule = module {
    factory { ImageDecoder() }
    single { getAppDatabase() }
    single { ApiClient() }

    // UploadViewModel은 MergeResultDao가 필요 (iOS 전용)
    factory { UploadViewModel(dao = get<com.example.twoeyesproject.dependency.AppDatabase>().getMergeResultDao(), client = get()) }
}