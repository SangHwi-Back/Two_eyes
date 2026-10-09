package com.example.twoeyesproject.feed.component

import com.arkivanov.decompose.ComponentContext
import org.koin.core.component.KoinComponent

class DefaultFeedSearchComponent(
    componentContext: ComponentContext,
    val onBack: () -> Unit,
) : FeedSearchComponent, ComponentContext by componentContext, KoinComponent {
    override fun onBackClick() =
        onBack()
}