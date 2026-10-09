package com.example.twoeyesproject.root.feed

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.router.stack.StackNavigation
import com.arkivanov.decompose.router.stack.childStack
import com.arkivanov.decompose.router.stack.pop
import com.arkivanov.decompose.router.stack.push
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.feed.DefaultFeedComponent
import com.example.twoeyesproject.feed.component.DefaultFeedSearchComponent
import com.example.twoeyesproject.feeddetail.DefaultFeedDetailComponent
import com.example.twoeyesproject.root.TabComponentElement

class DefaultFeedTabComponent(
    componentContext: ComponentContext
) : FeedTabComponent, TabComponentElement, ComponentContext by componentContext {
    override val navigation = StackNavigation<FeedTabConfig>()

    override val stack: Value<ChildStack<*, FeedTabComponent.Child>> =
        childStack(
            source = navigation,
            serializer = FeedTabConfig.serializer(),
            initialConfiguration = FeedTabConfig.Feed,
            childFactory = ::child
        )

    private fun child(config: FeedTabConfig, componentContext: ComponentContext) : FeedTabComponent.Child =
        when (config) {
            is FeedTabConfig.Feed ->
                FeedTabComponent.Child.Feed(DefaultFeedComponent(
                    componentContext = componentContext,
                    onFeedClick = { feedId ->
                        navigation.push(FeedTabConfig.FeedDetail(feedId))
                    },
                    onSearchClick = {
                        navigation.push(FeedTabConfig.FeedSearch)
                    }
                ))

            is FeedTabConfig.FeedDetail ->
                FeedTabComponent.Child.FeedDetail(
                    DefaultFeedDetailComponent(
                        componentContext = componentContext,
                        onBack = {
                            navigation.pop()
                        },
                    )
                )

            is FeedTabConfig.FeedSearch ->
                FeedTabComponent.Child.FeedSearch(
                    DefaultFeedSearchComponent(
                        componentContext = componentContext,
                        onBack = {
                            navigation.pop()
                        }
                    )
                )
        }
}