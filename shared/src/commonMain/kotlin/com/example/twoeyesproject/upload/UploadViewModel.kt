package com.example.twoeyesproject.upload

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.TwoEyesException
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.MergeResultDao
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.dependency.UploadMergedDTO
import com.example.twoeyesproject.feed.FeedItemModel
import com.example.twoeyesproject.feed.toFeedItemModel
import com.example.twoeyesproject.image.URIByteEncoder
import io.ktor.client.plugins.ResponseException
import kotlin.coroutines.cancellation.CancellationException
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class UploadViewModel(
    val dao: MergeResultDao,
    val client: ApiClient
): ViewModel() {

    // dao.getAllAsFlow() 가 Room 변경(insert/delete)을 자동으로 emit하므로
    // 별도 MutableStateFlow나 getAllEntities() 호출이 필요 없음
    var mergeEntities: StateFlow<List<MergeResultEntity>> = dao.getAllAsFlow().stateIn(
        scope = viewModelScope,
        started = SharingStarted.Lazily,
        initialValue = listOf()
    )

    @Throws(TwoEyesException::class, CancellationException::class)
    suspend fun deleteEntity(entity: MergeResultEntity) {
        try {
            dao.delete(entity)
        } catch (e: Exception) {
            throw TwoEyesException.Database(
                message = e.message ?: "Failed to delete entity",
                cause = e,
            )
        }
    }

    @Throws(TwoEyesException::class, CancellationException::class)
    suspend fun uploadEntity(dto: UploadMergedDTO): FeedItemModel {
        var result: ByteArray = byteArrayOf()
        for (id in dto.imageIds) {
            val item = URIByteEncoder(id).uriToByteArray()
                ?: throw TwoEyesException.Unknown(
                    message = "Failed to encode image: $id",
                    description = "이미지를 처리하는 중 문제가 발생했습니다.",
                )
            result += item
        }

        return try {
            val response = client.createFeed(
                content = dto.contents,
                tags = dto.tags,
                imageBytes = result,
            )
            response.toFeedItemModel()
        } catch (e: ResponseException) {
            throw TwoEyesException.Http(
                statusCode = e.response.status.value,
                message = e.message ?: "HTTP error during upload",
                cause = e,
            )
        } catch (e: Exception) {
            throw TwoEyesException.Network(
                message = e.message ?: "Network error during upload",
                cause = e,
            )
        }
    }
}
