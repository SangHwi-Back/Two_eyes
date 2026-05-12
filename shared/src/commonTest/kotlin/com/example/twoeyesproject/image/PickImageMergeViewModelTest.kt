package com.example.twoeyesproject.image

import com.example.twoeyesproject.image.merge.PickImageMergeViewModel
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals

class PickImageMergeViewModelTest {
    @Test
    fun `PickImageMergeViewModel initial states`() {
        val viewModel = PickImageMergeViewModel()

        assertEquals(viewModel.leading.value, PickImageMergeViewModel.ImageState())
        assertEquals(viewModel.trailing.value, PickImageMergeViewModel.ImageState())
    }

    @Test
    fun `PickImageMergeViewModel update states`() {
        val viewModel = PickImageMergeViewModel()

        assertEquals(viewModel.leading.value, viewModel.trailing.value)

        val newLeadingState = PickImageMergeViewModel.ImageState(20f, 20f, 0.5f)
        val newTrailingState = PickImageMergeViewModel.ImageState(-20f, -20f, 0.1f)

        viewModel.updateLeading(newLeadingState)
        viewModel.updateTrailing(newTrailingState)

        assertNotEquals(newLeadingState, newTrailingState)
        assertEquals(viewModel.leading.value, newLeadingState)
        assertEquals(viewModel.trailing.value, newTrailingState)
    }

    @Test
    fun `PickImageMergeViewModel update order`() {
        val viewModel = PickImageMergeViewModel()

        assertEquals(viewModel.zOrder.value.distinct().size, 2)

        val prevZOrder = viewModel.zOrder.value
        viewModel.swapOrder()

        assertEquals(viewModel.zOrder.value.distinct().size, 2)
        assertNotEquals(viewModel.zOrder.value, prevZOrder)
    }
}