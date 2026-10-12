package com.example.twoeyesproject.upload.component

import com.arkivanov.decompose.ComponentContext
import com.example.twoeyesproject.dependency.MergeResultEntity
import org.koin.core.component.KoinComponent

class DefaultUploadViewComponent(
    componentContext: ComponentContext,
    override val entity: MergeResultEntity,
    val onBack: () -> Unit,
) : UploadViewComponent, ComponentContext by componentContext, KoinComponent {
    override fun onBackClicked() =
        onBack()
}