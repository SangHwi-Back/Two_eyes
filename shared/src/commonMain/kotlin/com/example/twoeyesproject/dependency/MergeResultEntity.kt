package com.example.twoeyesproject.dependency

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.example.twoeyesproject.platformspecific.ImageSource
import kotlinx.serialization.Serializable

@Serializable
@Entity
data class MergeResultEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val resultId: String,
    val leadingImageId: String,
    val trailingImageId: String,
    val name: String?,
    val date: String,
    var isUploaded: Boolean,
)

@Serializable
data class UploadMergedDTO(
    var imageIds: List<ImageSource>,
    var tags: List<String>,
    var contents: String
)