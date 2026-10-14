package com.example.twoeyesproject.tabcontent

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import com.arkivanov.decompose.extensions.compose.subscribeAsState
import com.example.twoeyesproject.TopAppBarData
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.root.upload.UploadTabComponent
import com.example.twoeyesproject.ui.upload.UploadCreateFeedScreen
import com.example.twoeyesproject.ui.upload.UploadScreen

@Composable
fun UploadTabContent(
    component: UploadTabComponent,
    topAppBarDataChange: (TopAppBarData) -> Unit = {}
) {
    val stack by component.stack.subscribeAsState()
    when (val instance = stack.active.instance) {
        is UploadTabComponent.Child.UploadableListView ->
            UploadScreen(
                onNext = {
                    instance.component.onNextClicked(it)
                },
                topAppBarDataChange = topAppBarDataChange
            )
        is UploadTabComponent.Child.UploadView ->
            UploadCreateFeedScreen(
                entity = MergeResultEntity(
                    resultId = "",
                    leadingImageId = "",
                    trailingImageId = "",
                    name = null,
                    date = "",
                    isUploaded = false,
                ),
                topAppBarDataChange = topAppBarDataChange
            )
    }
}