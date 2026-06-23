package com.example.twoeyesproject.di

import org.koin.core.context.startKoin

/**
 * iOS에서 Koin을 초기화하는 함수
 * Swift에서 호출: KoinInitializerKt.initKoin()
 */
fun initKoin() {
    startKoin {
        modules(
            sharedCommonModule,  // 공통 모듈
            sharedIosModule      // iOS 전용 모듈
        )
    }
}