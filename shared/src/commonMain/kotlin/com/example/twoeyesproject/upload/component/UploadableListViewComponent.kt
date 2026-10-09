package com.example.twoeyesproject.upload.component

import com.example.twoeyesproject.dependency.MergeResultEntity

interface UploadableListViewComponent {
    fun onNextClicked(entity: MergeResultEntity)
}