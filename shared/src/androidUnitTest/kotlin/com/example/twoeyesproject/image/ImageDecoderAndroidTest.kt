package com.example.twoeyesproject.image

import android.app.Application
import android.net.Uri
import androidx.test.core.app.ApplicationProvider
import com.example.twoeyesproject.di.sharedAndroidModule
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin
import org.koin.core.context.stopKoin
import org.koin.test.KoinTest
import org.robolectric.RobolectricTestRunner
import kotlin.test.assertFailsWith

@RunWith(RobolectricTestRunner::class)
class ImageDecoderAndroidTest : KoinTest {

    @After
    fun tearDown() {
        stopKoin()
    }

    private fun setUp() {
        val app = ApplicationProvider.getApplicationContext<Application>()
        startKoin {
            androidContext(app)
            modules(sharedAndroidModule)
        }
    }

    @Test
    suspend fun `유효하지 않은 URI로 decode하면 예외가 발생한다`() {
        setUp()
        val decoder = ImageDecoder()
        val invalidSource = Uri.Builder()
            .scheme("content")
            .authority("invalid.provider")
            .path("0")

        assertFailsWith<Exception> {
            decoder.decode(invalidSource)
        }
    }
}
