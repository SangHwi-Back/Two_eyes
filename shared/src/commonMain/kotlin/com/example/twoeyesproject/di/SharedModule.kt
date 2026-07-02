package com.example.twoeyesproject.di

import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.AppDatabase
import com.example.twoeyesproject.feed.FeedListViewModel
import com.example.twoeyesproject.feed.FeedSearchViewModel
import com.example.twoeyesproject.image.PickImageViewModel
import com.example.twoeyesproject.image.merge.PickImageMergeViewModel
import com.example.twoeyesproject.upload.UploadViewModel
import org.koin.dsl.module

/**
 * 공통 DI 모듈
 * commonMain에 정의하여 Android와 iOS에서 공통으로 사용
 */
val sharedCommonModule = module {

    // ── Singleton: 앱 전체에서 하나의 인스턴스만 사용 ──
    single { ApiClient() }

    // ── ViewModels: 화면마다 새 인스턴스 생성 ──
    // commonMain에서는 viewModel() DSL을 사용할 수 없으므로 factory() 사용
    // LoginViewModel은 플랫폼 UIContext가 필요하므로 각 플랫폼에서 직접 생성 (DI 제외)
    factory { FeedListViewModel(apiClient = get()) }
    factory { FeedSearchViewModel(apiClient = get()) }
    factory { UploadViewModel(dao = get<AppDatabase>().getMergeResultDao(), client = get()) }
    factory { PickImageViewModel() }
    factory { PickImageMergeViewModel() }

    // UploadViewModel은 AppDatabase가 필요하므로 플랫폼별로 정의
}
