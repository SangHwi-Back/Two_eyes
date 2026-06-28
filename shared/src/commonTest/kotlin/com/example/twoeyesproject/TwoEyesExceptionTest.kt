package com.example.twoeyesproject

import com.example.twoeyesproject.dependency.MergeResultDao
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.upload.UploadViewModel
import com.example.twoeyesproject.dependency.ApiClient
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.test.runTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/**
 * TwoEyesException 래핑 및 AppErrorBus 전달 동작 검증.
 *
 * DAO / ApiClient 자체는 원본 예외를 그대로 던진다(기존 유닛 테스트 호환).
 * ViewModel 레이어가 이를 TwoEyesException 으로 변환 후 AppErrorBus 에 전달하는 것을 검증한다.
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

    @BeforeTest
    fun setup() {
        AppErrorBus.clear()
    }

    // ── deleteEntity ──────────────────────────────────────────────────────────

    @Test
    fun `deleteEntity posts Database error to AppErrorBus`() = runTest {
        viewModel.deleteEntity(sampleEntity)
        val error = AppErrorBus.error.value
        assertNotNull(error)
        assertEquals("데이터 오류", error.title)
    }

    @Test
    fun `AppErrorBus message is non-blank on database error`() = runTest {
        viewModel.deleteEntity(sampleEntity)
        val error = AppErrorBus.error.value
        assertNotNull(error)
        assertTrue(error.message.isNotBlank())
    }

    // ── toUserFacingError 변환 ─────────────────────────────────────────────────

    @Test
    fun `Database exception maps to correct title`() {
        val ex = TwoEyesException.Database(message = "test", cause = dbError)
        assertEquals("데이터 오류", ex.toUserFacingError().title)
    }

    @Test
    fun `Network exception maps to correct title`() {
        val ex = TwoEyesException.Network(message = "timeout")
        assertEquals("네트워크 오류", ex.toUserFacingError().title)
    }
}
