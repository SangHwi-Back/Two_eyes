package com.example.twoeyesproject.di

import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.getDatabaseBuilder
import com.example.twoeyesproject.dependency.getRoomDatabase
import com.example.twoeyesproject.feed.FeedListViewModel
import com.example.twoeyesproject.feed.FeedSearchViewModel
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
    single { ApiClient() }
    single { getRoomDatabase(getDatabaseBuilder(androidContext())) }
    single { AppLoginStatus() }

    // Android 에서는 ViewModel lifecycle 을 위해 viewModel {} DSL 사용
    // sharedCommonModule 의 factory {} 등록을 Android 에서 이걸로 대체
    viewModel { FeedListViewModel(apiClient = get()) }
    viewModel { FeedSearchViewModel(apiClient = get()) }
    viewModel { UploadViewModel(
        dao = get<com.example.twoeyesproject.dependency.AppDatabase>().getMergeResultDao(),
        client = get()
    ) }
}

data class AppLoginStatus(
    var isLoggedIn: Boolean = false,
    var showLoginSheet: Boolean = false,
)
