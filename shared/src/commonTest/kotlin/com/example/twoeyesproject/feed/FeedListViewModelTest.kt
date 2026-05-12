package com.example.twoeyesproject.feed

import com.example.twoeyesproject.dependency.ApiClient
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertNotNull

class FeedListViewModelTest {
    val apiClient = ApiClient()

    @Test
    fun `ListData should be 3`() {
        // Arrange
        val viewModel = FeedListViewModel(apiClient)

        // Act
        val items = viewModel.listData.value

        // Assert
        assertNotNull(items)
        assertEquals(items.size, 3)
    }

    @Test
    fun `First item should have correct author`() {
        // Arrange
        val viewModel = FeedListViewModel(apiClient)

        // Act
        val items = viewModel.listData.value

        // Assert
        assertNotNull(items)
        assertNotEquals(items.size, 0)
        assertEquals("mock_user_1", items[0].author)
    }

    @Test
    fun `All items should not show reply`() {
        // Arrange
        val viewModel = FeedListViewModel(apiClient)

        // Act
        viewModel.listData.value.forEach { item ->
            assertFalse(item.showReply)
        }
    }
}