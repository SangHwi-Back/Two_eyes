package com.example.twoeyesproject

import android.app.Application
import com.example.twoeyesproject.di.sharedAndroidModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class TwoEyesApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidContext(this@TwoEyesApplication)
            modules(sharedAndroidModule)

        }
    }
}
