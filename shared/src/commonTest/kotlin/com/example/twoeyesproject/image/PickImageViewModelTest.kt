package com.example.twoeyesproject.image

import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertNotSame
import kotlin.test.assertTrue
import kotlin.uuid.ExperimentalUuidApi

@OptIn(ExperimentalCoroutinesApi::class, ExperimentalUuidApi::class, ExperimentalCoroutinesApi::class)
class PickImageViewModelTest {
    @Test
    fun `Initial target state should be empty`() {
        // Arrange
        val viewModel = PickImageViewModel()
        val target = viewModel.target.value

        // Act, Assert
        assertFalse(target.leading.isHighlighted)
        assertFalse(target.trailing.isHighlighted)
    }

    @Test
    fun `Initial images should be empty`() {
        // Arrange
        val viewModel = PickImageViewModel()

        // Act, Assert
        assertTrue(viewModel.imageSources.value.isEmpty())
    }

    @Test
    fun `Highlight should change imageView`() {
        // Arrange
        val viewModel = PickImageViewModel()

        // Act
        viewModel.highlightImageView(viewModel.target.value.leading)

        // Assert
        assertTrue(viewModel.target.value.leading.isHighlighted)
        assertFalse(viewModel.target.value.trailing.isHighlighted)

        // Act
        viewModel.highlightImageView(viewModel.target.value.trailing)

        // Assert
        assertFalse(viewModel.target.value.leading.isHighlighted)
        assertTrue(viewModel.target.value.trailing.isHighlighted)

        // Act
        viewModel.highlightImageView(viewModel.target.value.trailing)

        // Assert
        assertFalse(viewModel.target.value.leading.isHighlighted)
        assertFalse(viewModel.target.value.trailing.isHighlighted)

        // Act
        viewModel.highlightImageView(viewModel.target.value.leading)

        // Assert
        assertTrue(viewModel.target.value.leading.isHighlighted)
        assertFalse(viewModel.target.value.trailing.isHighlighted)
    }

    @Test
    fun `Highlight should be only one`() {
        // Arrange
        val viewModel = PickImageViewModel()

        // Act
        viewModel.highlightImageView(viewModel.target.value.leading)

        assertTrue(viewModel.target.value.leading.isHighlighted)
        assertFalse(viewModel.target.value.trailing.isHighlighted)

        viewModel.highlightImageView(viewModel.target.value.trailing)

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