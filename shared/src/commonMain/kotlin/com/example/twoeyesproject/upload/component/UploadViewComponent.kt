package com.example.twoeyesproject.upload.component

import com.example.twoeyesproject.dependency.MergeResultEntity

interface UploadViewComponent {
    val entity: MergeResultEntity
    fun onBackClicked()
}