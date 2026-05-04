package com.example.twoeyesproject.upload

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.AppDatabase
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.dependency.UploadMergedDTO
import com.example.twoeyesproject.image.URIByteEncoder
import com.example.twoeyesproject.platformspecific.convertToString
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class UploadViewModel(db: AppDatabase): ViewModel() {

    private val dao = db.getMergeResultDao()
    private val client = ApiClient()

    // dao.getAllAsFlow() 가 Room 변경(insert/delete)을 자동으로 emit하므로
    // 별도 MutableStateFlow나 getAllEntities() 호출이 필요 없음
    val mergeEntities: StateFlow<List<MergeResultEntity>> = dao.getAllAsFlow().stateIn(
        scope = viewModelScope,
        started = SharingStarted.Lazily,
        initialValue = listOf()
    )

    fun deleteEntity(entity: MergeResultEntity) {
        viewModelScope.launch {
            dao.delete(entity)
            // Flow가 Room 변경을 자동 감지하므로 mergeEntities 별도 갱신 불필요
        }
    }

    fun uploadEntity(dto: UploadMergedDTO) {
        viewModelScope.launch {
            var result: ByteArray = byteArrayOf()
            for (id in dto.imageIds) {
                val item = URIByteEncoder(id.convertToString()).uriToByteArray()
                if (item != null) {
                    result += item
                } else {
                    throw RuntimeException()
                }
            }

            client.createFeed(accessToken = "", content = dto.contents, tags = dto.tags, imageBytes = result)
        }
    }
}
