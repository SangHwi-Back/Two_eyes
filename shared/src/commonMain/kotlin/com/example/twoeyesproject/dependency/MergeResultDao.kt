package com.example.twoeyesproject.dependency

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import androidx.room.Upsert
import kotlinx.coroutines.flow.Flow

@Dao
interface MergeResultDao {
    @Delete
    suspend fun delete(item: MergeResultEntity)

    @Transaction
    @Delete
    suspend fun deleteAndGetAll(item: MergeResultEntity): List<MergeResultEntity> {
        delete(item)
        return getAll()
    }

    @Upsert
    suspend fun save(item: MergeResultEntity): Long
    @Transaction
    @Upsert
    suspend fun saveAndGetAll(item: MergeResultEntity): List<MergeResultEntity> {
        save(item)
        return getAll()
    }

    @Query("SELECT count(*) FROM MergeResultEntity")
    suspend fun count(): Int

    @Query("SELECT * FROM MergeResultEntity")
    fun getAllAsFlow(): Flow<List<MergeResultEntity>>

    @Query("SELECT * FROM MergeResultEntity")
    suspend fun getAll(): List<MergeResultEntity>
}