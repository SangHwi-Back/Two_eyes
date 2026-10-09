package com.example.twoeyesproject.image.component

import com.arkivanov.decompose.ComponentContext
import org.koin.core.component.KoinComponent

class DefaultMergeImageViewComponent(
    componentContext: ComponentContext,
    override val encoded1: String,
    override val encoded2: String,
    val onBack: () -> Unit,
    val onConfirm: () -> Unit,
) : MergeImageViewComponent, ComponentContext by componentContext, KoinComponent {
    override fun onBackClicked() =
        onBack()

    override fun onConfirmClicked() =
        onConfirm()
}