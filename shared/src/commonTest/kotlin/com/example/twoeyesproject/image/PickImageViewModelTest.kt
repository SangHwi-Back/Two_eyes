package com.example.twoeyesproject.image

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertNotSame
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlin.uuid.ExperimentalUuidApi

class PickImageViewModelTest {
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
        val leadingModel = viewModel.target.value.leading

        // Act
        viewModel.highlightImageView(leadingModel)

        // Assert
        assertTrue(viewModel.target.value.leading.isHighlighted)
    }

    @OptIn(ExperimentalUuidApi::class)
    @Test
    fun `Is two targets differentiated`() {
        // Arrange
        val viewModel = PickImageViewModel()
        val target = viewModel.target.value

        assertNotSame(target.leading.uuid, target.trailing.uuid)
    }
}