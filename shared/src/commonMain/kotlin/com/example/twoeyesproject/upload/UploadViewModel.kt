package com.example.twoeyesproject.upload

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.MergeResultDao
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.dependency.UploadMergedDTO
import com.example.twoeyesproject.feed.FeedItemModel
import com.example.twoeyesproject.feed.toFeedItemModel
import com.example.twoeyesproject.image.URIByteEncoder
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

    suspend fun deleteEntity(entity: MergeResultEntity) {
        dao.delete(entity)
        // Flow가 Room 변경을 자동 감지하므로 mergeEntities 별도 갱신 불필요
    }

    suspend fun uploadEntity(dto: UploadMergedDTO): FeedItemModel {
        var result: ByteArray = byteArrayOf()
        for (id in dto.imageIds) {
            val item = URIByteEncoder(id).uriToByteArray()
            if (item != null) {
                result += item
            } else {
                throw RuntimeException()
            }
        }

        val response = client.createFeed(content = dto.contents, tags = dto.tags, imageBytes = result)
        return response.toFeedItemModel()
    }
}
