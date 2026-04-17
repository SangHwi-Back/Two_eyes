package com.example.twoeyesproject.image

import android.app.Application
import android.graphics.Bitmap
import android.net.Uri
import androidx.test.core.app.ApplicationProvider
import com.example.twoeyesproject.di.sharedAndroidModule
import com.example.twoeyesproject.shared.R
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.Test
import org.junit.runner.RunWith
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin
import org.koin.core.context.stopKoin
import org.robolectric.RobolectricTestRunner
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.uuid.ExperimentalUuidApi

@RunWith(RobolectricTestRunner::class)
@OptIn(ExperimentalCoroutinesApi::class, ExperimentalUuidApi::class)
class PickImageViewModelAndroidTest {
    private val testDispatcher = StandardTestDispatcher()

    @BeforeTest
    fun setUp() {
        Dispatchers.setMain(testDispatcher)       // 가짜 Main 등록
    }


    @AfterTest
    fun tearDown() {
        Dispatchers.resetMain()                   // 원래대로 복원
    }

    @Test
    fun `Set image on viewModel`() {
        // Arrange
        val viewModel = PickImageViewModel()

        // Act
        viewModel.setImage(Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888))

        // Assert
        assertNull(viewModel.target.value.leading.image)
        assertNull(viewModel.target.value.trailing.image)

        // Act
        viewModel.highlightImageView(viewModel.target.value.leading)
        testDispatcher.scheduler.advanceUntilIdle()
        val imageSetLeading = Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888)
        viewModel.setImage(imageSetLeading)

        // Assert
        assertNotNull(viewModel.target.value.leading.image)
        assertEquals(viewModel.target.value.leading.image, imageSetLeading)
        assertNull(viewModel.target.value.trailing.image)

        // Act
        val originalTrailingUuid = viewModel.target.value.trailing.uuid
        viewModel.highlightImageView(viewModel.target.value.trailing)
        testDispatcher.scheduler.advanceUntilIdle()
        val imageSetTrailing = Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888)
        viewModel.setImage(imageSetTrailing)

        // Assert
        assertNotNull(viewModel.target.value.leading.image)
        assertNotNull(viewModel.target.value.trailing.image)
        assertEquals(imageSetTrailing, viewModel.target.value.trailing.image)
        // trailing 슬롯의 UUID가 바뀌지 않았는지 확인 — leading 데이터로 덮어쓰는 버그 검출
        assertEquals(originalTrailingUuid, viewModel.target.value.trailing.uuid, "[Unit Test] Trailing slot was overwritten with leading data")
    }

    @Test
    fun `Set image from source on viewModel`() = runTest {
        val app = ApplicationProvider.getApplicationContext<Application>()
        startKoin {
            androidContext(app)
            modules(sharedAndroidModule)
        }

        val viewModel = PickImageViewModel()
        val uri = Uri.parse("android.res://com.example.twoeyesproject.shared/${R.drawable.lenna}")

        // ── Case 1: leading 하이라이트 ───────────────────────────────────────────
        viewModel.highlightImageView(viewModel.target.value.leading)
        testDispatcher.scheduler.advanceUntilIdle()

        viewModel.setImageFromSource(uri.buildUpon())

        assertNotNull(viewModel.target.value.leading.image, "[Unit Test] Leading image is not inserted")
        assertNull(viewModel.target.value.trailing.image)

        // ── Case 2: trailing 하이라이트 — 버그를 잡는 케이스 ──────────────────
        val originalTrailingUuid = viewModel.target.value.trailing.uuid  // 원래 UUID 저장

        viewModel.highlightImageView(viewModel.target.value.trailing)
        testDispatcher.scheduler.advanceUntilIdle()

        viewModel.setImageFromSource(uri.buildUpon())

        assertNotNull(viewModel.target.value.trailing.image)
        // UUID가 leading 것으로 교체됐으면 여기서 실패 → 버그 검출
        assertEquals(originalTrailingUuid, viewModel.target.value.trailing.uuid, "[Unit Test] Trailing image is not inserted")

        stopKoin()
    }

    @Test
    fun `Delete image on viewModel`() {
        // Arrange
        val viewModel = PickImageViewModel()

        // Act
        viewModel.highlightImageView(viewModel.target.value.leading)
        testDispatcher.scheduler.advanceUntilIdle()
        viewModel.setImage(Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888))

        // Assert
        assertNotNull(viewModel.target.value.leading.image)
        assertNull(viewModel.target.value.trailing.image)

        // Act
        viewModel.deleteImage(viewModel.target.value.leading)

        // Assert
        assertNull(viewModel.target.value.leading.image)
        assertNull(viewModel.target.value.trailing.image)
    }
}