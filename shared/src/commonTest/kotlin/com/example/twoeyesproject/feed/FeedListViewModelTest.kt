package com.example.twoeyesproject.feed

import com.example.twoeyesproject.dependency.ApiClient
import kotlinx.coroutines.test.runTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue

class FeedListViewModelTest {
    private lateinit var viewModel: FeedListViewModel

    @BeforeTest
    fun setup() = runTest {
        viewModel = FeedListViewModel(ApiClient().apply {
            setTestClientStatus(isTest = true)
        })
        viewModel.getAllFeeds()
    }

    @Test
    fun `ListData should be 3`() = runTest {
        // Assert
        assertEquals(3, viewModel.listData.value.size)
    }

    @Test
    fun `First item should have correct author`() = runTest {
        // Arrange
        val items = viewModel.listData.value

        // Assert
        assertNotEquals(0, items.size)
        assertEquals("mock_user_1", items[0].author)
    }

    @Test
    fun `Update like`() = runTest {
        // Arrange
        val item = viewModel.listData.value.first()

        // Act
        val result = viewModel.updateLike(true, item.feedId)

        // Assert
        assertEquals(true, result?.isLiked)

        val status = viewModel.listData.value.firstOrNull { it.feedId == item.feedId }
        if (status != null)
            assertEquals(true, status.isUserLiked)
        else
            assertTrue(false, "Item with feedId ${item.feedId} not found")
    }

    @Test
    fun `All items should not show reply`() = runTest {
        // Act & Assert
        viewModel.listData.value.forEach { item ->
            assertFalse(item.showReply)
        }
    }
}