package com.example.twoeyesproject

import android.app.Application
import com.example.twoeyesproject.di.sharedAndroidModule
import com.example.twoeyesproject.di.sharedCommonModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class TwoEyesApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidContext(this@TwoEyesApplication)
            modules(
                sharedCommonModule,  // 공통 모듈
                sharedAndroidModule  // Android 전용 모듈
            )
        }
    }
}
