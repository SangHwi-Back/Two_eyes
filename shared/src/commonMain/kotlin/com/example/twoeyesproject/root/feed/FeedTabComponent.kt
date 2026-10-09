package com.example.twoeyesproject.root.feed

import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.feed.FeedComponent
import com.example.twoeyesproject.feed.component.FeedSearchComponent
import com.example.twoeyesproject.feeddetail.FeedDetailComponent
import kotlinx.serialization.Serializable

interface FeedTabComponent {
    val stack: Value<ChildStack<*, Child>>

    sealed interface Child {
        data class Feed(val component: FeedComponent) : Child
        data class FeedDetail(val component: FeedDetailComponent) : Child
        data class FeedSearch(val component: FeedSearchComponent) : Child
    }
}

@Serializable
sealed interface FeedTabConfig {
    @Serializable
    data object Feed : FeedTabConfig

    @Serializable
    data class FeedDetail(val feedId: String) : FeedTabConfig

    @Serializable
    data object FeedSearch : FeedTabConfig

}