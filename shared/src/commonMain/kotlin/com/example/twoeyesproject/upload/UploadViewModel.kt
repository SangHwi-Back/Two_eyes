package com.example.twoeyesproject.upload

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.dependency.AppDatabase
import com.example.twoeyesproject.dependency.MergeResultEntity
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class UploadViewModel(db: AppDatabase): ViewModel() {
    private var _mergeEntities = MutableStateFlow<List<MergeResultEntity>>(listOf())
    val mergeEntities: StateFlow<List<MergeResultEntity>>

    private val dao = db.getMergeResultDao()

    init {
        mergeEntities = dao.getAllAsFlow().stateIn(
            scope = viewModelScope,
            started = SharingStarted.Lazily,
            initialValue = listOf())
    }

    fun getAllEntities() {
        viewModelScope.launch {
            _mergeEntities.value = dao.getAll()
        }
    }

    fun deleteEntity(entity: MergeResultEntity) {
        viewModelScope.launch {
            _mergeEntities.value = dao.deleteAndGetAll(entity)
        }
    }

    fun uploadEntity(entity: MergeResultEntity) {
        // TODO: Ktor 사용한 서버 업로드
    }
}