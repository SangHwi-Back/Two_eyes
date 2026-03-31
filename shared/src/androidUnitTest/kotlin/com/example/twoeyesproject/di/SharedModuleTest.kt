package com.example.twoeyesproject.di

import android.app.Application
import androidx.test.core.app.ApplicationProvider
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin
import org.koin.core.context.stopKoin
import org.koin.test.KoinTest
import org.koin.test.check.checkModules
import org.koin.test.verify.Verify
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class SharedModuleTest : KoinTest {

    @After
    fun tearDown() {
        stopKoin()
    }

    @Test
    fun `sharedAndroidModule이 올바르게 구성됐다`() {
        val app = ApplicationProvider.getApplicationContext<Application>()
        startKoin {
            androidContext(app)
            modules(sharedAndroidModule)
        }
    }
}
