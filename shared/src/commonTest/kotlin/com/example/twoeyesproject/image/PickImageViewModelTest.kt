package com.example.twoeyesproject.image

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertNotSame
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlin.uuid.ExperimentalUuidApi

@OptIn(ExperimentalCoroutinesApi::class, ExperimentalUuidApi::class)
class PickImageViewModelTest {
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
    fun `Initial target state should be empty`() {
        // Arrange
        val viewModel = PickImageViewModel()
        val target = viewModel.target.value

        // Act, Assert
        assertNull(target.leading.image)
        assertNull(target.trailing.image)
        assertFalse(target.leading.isHighlighted)
        assertFalse(target.trailing.isHighlighted)
    }

    @Test
    fun `Initial images should be empty`() {
        // Arrange
        val viewModel = PickImageViewModel()

        // Act, Assert
        assertTrue(viewModel.imageSources.value.isEmpty())
        // viwModel.images 가 필요없나?
        assertTrue(viewModel.images.value.isEmpty())
    }

    @Test
    fun `Highlight should change imageView`() {
        // Arrange
        val viewModel = PickImageViewModel()

        // Act
        viewModel.highlightImageView(viewModel.target.value.leading)
        testDispatcher.scheduler.advanceUntilIdle()

        // Assert
        assertTrue(viewModel.target.value.leading.isHighlighted)
    }

    @Test
    fun `Highlight should be only one`() {
        // Arrange
        val viewModel = PickImageViewModel()

        // Act
        viewModel.highlightImageView(viewModel.target.value.leading)
        testDispatcher.scheduler.advanceUntilIdle()

        assertTrue(viewModel.target.value.leading.isHighlighted)
        assertFalse(viewModel.target.value.trailing.isHighlighted)

        viewModel.highlightImageView(viewModel.target.value.trailing)
        testDispatcher.scheduler.advanceUntilIdle()

        // Assert
        assertTrue(viewModel.target.value.trailing.isHighlighted)
        assertFalse(viewModel.target.value.leading.isHighlighted)
    }

    @Test
    fun `Is two targets differentiated`() {
        // Arrange
        val viewModel = PickImageViewModel()
        val target = viewModel.target.value

        assertNotSame(target.leading.uuid, target.trailing.uuid)
    }
}