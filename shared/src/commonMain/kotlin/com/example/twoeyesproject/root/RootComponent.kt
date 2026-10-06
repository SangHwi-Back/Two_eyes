package com.example.twoeyesproject.root

import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.feed.FeedComponent
import com.example.twoeyesproject.feeddetail.FeedDetailComponent
import kotlinx.serialization.Serializable

interface RootComponent {
    val stack : Value<ChildStack<*, Child>>
    fun onBackClicked()
    sealed interface Child {
        data class Feed(val component: FeedComponent) : Child
        data class FeedDetail(val component: FeedDetailComponent) : Child
    }
}

@Serializable
sealed interface Config {
    @Serializable
    data object Feed : Config

    @Serializable
    data class FeedDetail(val feedId: String) : Config
}