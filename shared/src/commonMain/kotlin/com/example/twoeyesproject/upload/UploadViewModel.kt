package com.example.twoeyesproject.upload

import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.TwoEyesException
import com.example.twoeyesproject.TwoEyesViewModel
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.MergeResultDao
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.dependency.UploadMergedDTO
import com.example.twoeyesproject.feed.FeedItemModel
import com.example.twoeyesproject.feed.toFeedItemModel
import com.example.twoeyesproject.image.URIByteEncoder
import io.ktor.client.plugins.ResponseException
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class UploadViewModel(
    val dao: MergeResultDao,
    val client: ApiClient
) : TwoEyesViewModel() {

    var mergeEntities: StateFlow<List<MergeResultEntity>> = dao.getAllAsFlow().stateIn(
        scope = viewModelScope,
        started = SharingStarted.Lazily,
        initialValue = listOf()
    )

    suspend fun deleteEntity(entity: MergeResultEntity) {
        try {
            dao.delete(entity)
        } catch (e: Exception) {
            emitError(TwoEyesException.Database(
                message = e.message ?: "Failed to delete entity",
                cause = e,
            ))
        }
    }

    suspend fun uploadEntity(dto: UploadMergedDTO): FeedItemModel? {
        var result: ByteArray = byteArrayOf()
        for (id in dto.imageIds) {
            val item = URIByteEncoder(id).uriToByteArray()
            if (item == null) {
                emitError(TwoEyesException.Unknown(
                    message = "Failed to encode image: $id",
                    description = "이미지를 처리하는 중 문제가 발생했습니다.",
                ))
                return null
            }
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
            emitError(TwoEyesException.Http(
                statusCode = e.response.status.value,
                message = e.message ?: "HTTP error during upload",
                cause = e,
            ))
            null
        } catch (e: Exception) {
            emitError(TwoEyesException.Network(
                message = e.message ?: "Network error during upload",
                cause = e,
            ))
            null
        }
    }
}
