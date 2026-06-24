package com.example.twoeyesproject.feed

import com.example.twoeyesproject.dependency.ApiClient
import kotlinx.coroutines.delay
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertNotNull

class FeedListViewModelTest {
    val viewModel = FeedListViewModel(ApiClient().apply {
        setTestClientStatus(isTest = true)
    })

    @Test
    fun `ListData should be 3`() = runTest {
        // Act
        viewModel.getAllFeeds()

        // Assert
        assertEquals(3, viewModel.listData.value.size)
    }

    @Test
    fun `First item should have correct author`() = runTest {
        // Act
        viewModel.getAllFeeds()
        val items = viewModel.listData.value

        // Assert
        assertNotNull(items)
        assertNotEquals(items.size, 0)
        assertEquals("mock_user_1", items[0].author)
    }

    @Test
    fun `All items should not show reply`() {
        // Act
        viewModel.listData.value.forEach { item ->

            // Assert
            assertFalse(item.showReply)
        }
    }
}