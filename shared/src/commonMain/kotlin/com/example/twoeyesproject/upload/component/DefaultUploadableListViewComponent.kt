package com.example.twoeyesproject.upload.component

import com.arkivanov.decompose.ComponentContext
import com.example.twoeyesproject.dependency.MergeResultEntity
import org.koin.core.component.KoinComponent

class DefaultUploadableListViewComponent(
    componentContext: ComponentContext,
    val onNext: (MergeResultEntity) -> Unit,
) : UploadableListViewComponent, ComponentContext by componentContext, KoinComponent {
    override fun onNextClicked(entity: MergeResultEntity) =
        onNext(entity)
}