package com.example.twoeyesproject.image

import android.graphics.Bitmap
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.assertNotNull
import kotlin.test.assertNull

@RunWith(RobolectricTestRunner::class)
@OptIn(ExperimentalCoroutinesApi::class)
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
        viewModel.setImage(Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888))

        // Assert
        assertNotNull(viewModel.target.value.leading.image)
        assertNull(viewModel.target.value.trailing.image)

        // Act
        viewModel.highlightImageView(viewModel.target.value.trailing)
        testDispatcher.scheduler.advanceUntilIdle()
        viewModel.setImage(Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888))

        // Assert
        assertNotNull(viewModel.target.value.leading.image)
        assertNotNull(viewModel.target.value.trailing.image)
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