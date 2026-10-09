package com.example.twoeyesproject.root.upload

import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.upload.component.UploadViewComponent
import com.example.twoeyesproject.upload.component.UploadableListViewComponent
import kotlinx.serialization.Serializable

interface UploadTabComponent {
    val stack: Value<ChildStack<*, Child>>

    sealed interface Child {
        data class UploadableListView(val component: UploadableListViewComponent) : Child
        data class UploadView(val component: UploadViewComponent) : Child
    }
}

@Serializable
sealed interface UploadTabConfig {
    @Serializable
    data object UploadableList: UploadTabConfig
    @Serializable
    data class UploadView(val entity: MergeResultEntity) : UploadTabConfig
}