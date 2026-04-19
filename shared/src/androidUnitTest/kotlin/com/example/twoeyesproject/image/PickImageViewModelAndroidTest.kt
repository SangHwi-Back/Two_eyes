package com.example.twoeyesproject.image

import android.app.Application
import android.net.Uri
import androidx.test.core.app.ApplicationProvider
import com.example.twoeyesproject.di.sharedAndroidModule
import com.example.twoeyesproject.shared.R
import kotlinx.coroutines.ExperimentalCoroutinesApi
import org.junit.Test
import org.junit.runner.RunWith
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin
import org.koin.core.context.stopKoin
import org.robolectric.RobolectricTestRunner
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.uuid.ExperimentalUuidApi

@RunWith(RobolectricTestRunner::class)
@OptIn(ExperimentalCoroutinesApi::class, ExperimentalUuidApi::class)
class PickImageViewModelAndroidTest {
    @Test
    fun `Set image on viewModel`() {
        // Arrange
        val viewModel = PickImageViewModel()
        val uri = Uri.parse("android.res://com.example.twoeyesproject.shared/${R.drawable.lenna}")

        // Act
        viewModel.setImageFromSource(uri.buildUpon())

        // Assert
        assertNull(viewModel.target.value.leading.imageSource)
        assertNull(viewModel.target.value.trailing.imageSource)

        // Act
        viewModel.highlightImageView(viewModel.target.value.leading)
        val imageSetLeading = Uri.parse("android.res://com.example.twoeyesproject.shared/${R.drawable.lenna}")
        viewModel.setImageFromSource(imageSetLeading.buildUpon())

        // Assert
        assertNotNull(viewModel.target.value.leading.imageSource)
        assertEquals(viewModel.target.value.leading.imageSource.toString(), imageSetLeading.toString())
        assertNull(viewModel.target.value.trailing.imageSource)

        // Act
        val originalTrailingUuid = viewModel.target.value.trailing.uuid
        viewModel.highlightImageView(viewModel.target.value.trailing)
        val imageSetTrailing = Uri.parse("android.res://com.example.twoeyesproject.shared/${R.drawable.lenna}")
        viewModel.setImageFromSource(imageSetTrailing.buildUpon())

        // Assert
        assertNotNull(viewModel.target.value.leading.imageSource)
        assertNotNull(viewModel.target.value.trailing.imageSource)
        assertEquals(imageSetTrailing.toString(), viewModel.target.value.trailing.imageSource.toString())
        // trailing 슬롯의 UUID가 바뀌지 않았는지 확인 — leading 데이터로 덮어쓰는 버그 검출
        assertEquals(originalTrailingUuid, viewModel.target.value.trailing.uuid, "[Unit Test] Trailing slot was overwritten with leading data")
    }

    @Test
    fun `Set image from source on viewModel`() {
        val app = ApplicationProvider.getApplicationContext<Application>()
        startKoin {
            androidContext(app)
            modules(sharedAndroidModule)
        }

        val viewModel = PickImageViewModel()
        val uri = Uri.parse("android.res://com.example.twoeyesproject.shared/${R.drawable.lenna}")

        // ── Case 1: leading 하이라이트 ───────────────────────────────────────────
        viewModel.highlightImageView(viewModel.target.value.leading)

        viewModel.setImageFromSource(uri.buildUpon())

        assertNotNull(viewModel.target.value.leading.imageSource, "[Unit Test] Leading image is not inserted")
        assertNull(viewModel.target.value.trailing.imageSource)

        // ── Case 2: trailing 하이라이트 — 버그를 잡는 케이스 ──────────────────
        val originalTrailingUuid = viewModel.target.value.trailing.uuid  // 원래 UUID 저장

        viewModel.highlightImageView(viewModel.target.value.trailing)

        viewModel.setImageFromSource(uri.buildUpon())

        assertNotNull(viewModel.target.value.trailing.imageSource)
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
        viewModel.setImageFromSource(Uri.parse("android.res://com.example.twoeyesproject.shared/${R.drawable.lenna}").buildUpon())

        // Assert
        assertNotNull(viewModel.target.value.leading.imageSource)
        assertNull(viewModel.target.value.trailing.imageSource)

        // Act
        viewModel.deleteImage(viewModel.target.value.leading)

        // Assert
        assertNull(viewModel.target.value.leading.imageSource)
        assertNull(viewModel.target.value.trailing.imageSource)
    }
}