package com.example.twoeyesproject

import com.example.twoeyesproject.dependency.MergeResultDao
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.upload.UploadViewModel
import com.example.twoeyesproject.dependency.ApiClient
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertIs
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

/**
 * TwoEyesException 래핑 동작 검증.
 *
 * DAO / ApiClient 자체는 원본 예외를 그대로 던진다(기존 유닛 테스트 호환).
 * ViewModel 레이어가 이를 TwoEyesException 으로 변환하는 것만 여기서 검증한다.
 */
class TwoEyesExceptionTest {

    private val dbError = IllegalStateException("SQLite: database is locked")

    /** delete() 가 예외를 던지는 DAO */
    private val throwingDao = object : MergeResultDao {
        private val _flow = MutableStateFlow(emptyList<MergeResultEntity>())
        override fun getAllAsFlow(): Flow<List<MergeResultEntity>> = _flow.asStateFlow()
        override suspend fun getAll(): List<MergeResultEntity> = emptyList()
        override suspend fun get(id: Long): MergeResultEntity? = null
        override suspend fun save(item: MergeResultEntity): Long = 0L
        override suspend fun count(): Int = 0
        override suspend fun delete(item: MergeResultEntity): Unit = throw dbError
    }

    private val mockApiClient = ApiClient().apply { setTestClientStatus(isTest = true) }

    private val viewModel = UploadViewModel(dao = throwingDao, client = mockApiClient)

    private val sampleEntity = MergeResultEntity(
        resultId = "r",
        leadingImageId = "l",
        trailingImageId = "t",
        name = "test",
        date = "2026-01-01",
        isUploaded = false,
    )

    // ── deleteEntity ──────────────────────────────────────────────────────────

    @Test
    fun `deleteEntity wraps DAO exception as TwoEyesException Database`() = runTest {
        val result = runCatching { viewModel.deleteEntity(sampleEntity) }
        assertIs<TwoEyesException.Database>(result.exceptionOrNull())
    }

    @Test
    fun `TwoEyesException Database preserves original cause`() = runTest {
        val result = runCatching { viewModel.deleteEntity(sampleEntity) }
        val ex = result.exceptionOrNull()
        assertIs<TwoEyesException.Database>(ex)
        assertIs<IllegalStateException>(ex.cause)
        assertEquals(dbError.message, ex.cause?.message)
    }

    @Test
    fun `TwoEyesException Database has non-empty description`() = runTest {
        val result = runCatching { viewModel.deleteEntity(sampleEntity) }
        val ex = result.exceptionOrNull()
        assertIs<TwoEyesException.Database>(ex)
        assertNotNull(ex.description)
        assert(ex.description.isNotBlank())
    }
}
