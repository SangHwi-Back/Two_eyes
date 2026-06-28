package com.example.twoeyesproject.upload

import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.MergeResultDao
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.dependency.UploadMergedDTO
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

/**
 * UploadViewModel 유닛테스트
 */
class UploadViewModelTest {

    // Mock DAO
    private val mockDao = object : MergeResultDao {
        private val entities = MutableStateFlow(mutableListOf<MergeResultEntity>())
        override fun getAllAsFlow() = entities.asStateFlow()
        override suspend fun getAll(): List<MergeResultEntity> = entities.value
        override suspend fun get(id: Long): MergeResultEntity? = null
        override suspend fun save(item: MergeResultEntity): Long {
            entities.value.add(item)
            return item.id
        }
        override suspend fun count(): Int = entities.value.size
        override suspend fun delete(item: MergeResultEntity) {
            entities.value.remove(item)
        }
    }

    private val mockAPIClient = ApiClient().apply {
        setTestClientStatus(isTest = true)
    }

    private val viewModel = UploadViewModel(dao = mockDao, client = mockAPIClient)

    @Test
    fun `UploadViewModel should initialize with empty entities`() = runTest {
        // Arrange
        // Act
        val entities = viewModel.mergeEntities.value

        // Assert
        assertEquals(0, entities.size, "Initial entities should be empty")
    }

    @Test
    fun `uploadEntity should return FeedItemModel with correct data`() = runTest {
        // Arrange
        val dto = UploadMergedDTO(
            imageIds = listOf(),  // 빈 리스트로 URIByteEncoder 우회
            tags = mutableListOf("test", "upload"),
            contents = "Test upload content"
        )

        // Act
        val result = viewModel.uploadEntity(dto)

        // Assert
        assertNotNull(result, "Upload result should not be null")
        assertEquals("feed-new-001", result.feedId, "Feed ID should match mock response")
        assertEquals("Test upload content", result.description, "Content should match")
        assertEquals(1, result.imageUrls.size, "Should have 1 image")
        assertEquals("test_user", result.author, "Author should match mock user")
        assertEquals(0, result.likes, "Initial likes should be 0")
    }

    @Test
    fun `deleteEntity should remove entity from database`() = runTest {
        // Arrange
        val entity = MergeResultEntity(
            resultId = "test-id",
            leadingImageId = "leading",
            trailingImageId = "trailing",
            name = "Test",
            date = "2024-01-01",
            isUploaded = false
        )

        mockDao.save(entity)
        assertEquals(1, mockDao.getAll().size)

        // Act
        viewModel.deleteEntity(entity)

        // Assert
        assertEquals(0, mockDao.getAll().size, "Entity should be deleted")
    }
}
