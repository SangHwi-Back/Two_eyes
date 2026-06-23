package com.example.twoeyesproject.upload

import androidx.room.InvalidationTracker
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.AppDatabase
import com.example.twoeyesproject.dependency.MergeResultDao
import com.example.twoeyesproject.dependency.MergeResultEntity
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runTest
import org.koin.core.context.startKoin
import org.koin.core.context.stopKoin
import org.koin.dsl.module
import org.koin.test.KoinTest
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals

/**
 * UploadViewModel 유닛테스트
 *
 * Koin을 사용하여 의존성 주입 테스트
 */
class UploadViewModelTest : KoinTest {

    // Mock DAO
    private val mockDao = object : MergeResultDao {
        private val entities = mutableListOf<MergeResultEntity>()

        override fun getAllAsFlow() = flowOf(entities)
        override suspend fun getAll(): List<MergeResultEntity> = entities
        override suspend fun save(item: MergeResultEntity): Long {
            entities.add(item)
            return item.id
        }
        override suspend fun count(): Int = entities.size

        override suspend fun delete(item: MergeResultEntity) { entities.remove(item) }
    }

    // Mock Database
    private val mockDatabase = object : AppDatabase() {
        override fun getMergeResultDao() = mockDao
        override fun createInvalidationTracker(): InvalidationTracker {
            TODO("Not yet implemented")
        }
    }

    @BeforeTest
    fun setup() {
        // Koin 초기화 (테스트용 모듈)
        startKoin {
            modules(module {
                single<AppDatabase> { mockDatabase }
                single { ApiClient() }
            })
        }
    }

    @AfterTest
    fun tearDown() {
        stopKoin()
    }

    @Test
    fun `UploadViewModel should initialize with empty entities`() = runTest {
        // Arrange
        val viewModel = UploadViewModel(mockDatabase)

        // Act
        val entities = viewModel.mergeEntities.value

        // Assert
        assertEquals(0, entities.size, "Initial entities should be empty")
    }

    @Test
    fun `deleteEntity should remove entity from database`() = runTest {
        // Arrange
        val viewModel = UploadViewModel(mockDatabase)
        val entity = MergeResultEntity(
            resultId = "test-id",
            leadingImageId = "leading",
            trailingImageId = "trailing",
            name = "Test",
            date = "2024-01-01",
            isUploaded = false
        )

        // Mock에 엔티티 추가
        mockDao.save(entity)
        assertEquals(1, mockDao.getAll().size)

        // Act
        viewModel.deleteEntity(entity)

        // Assert
        // Flow 업데이트를 기다리기 위해 약간의 지연
        kotlinx.coroutines.delay(100)
        assertEquals(0, mockDao.getAll().size, "Entity should be deleted")
    }
}
