package com.example.twoeyesproject.upload.component

import com.arkivanov.decompose.ComponentContext
import org.koin.core.component.KoinComponent

class DefaultUploadViewComponent(
    componentContext: ComponentContext,
    val onBack: () -> Unit,
) : UploadViewComponent, ComponentContext by componentContext, KoinComponent {
    override fun onBackClicked() =
        onBack()
}