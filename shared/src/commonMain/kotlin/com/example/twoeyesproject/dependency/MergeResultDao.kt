package com.example.twoeyesproject.dependency

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface MergeResultDao {
    @Insert
    suspend fun insert(item: MergeResultEntity)

    @Query("SELECT count(*) FROM MergeResultEntity")
    suspend fun count(): Int

    @Query("SELECT * FROM MergeResultEntity")
    fun getAllAsFlow(): Flow<List<MergeResultEntity>>
}