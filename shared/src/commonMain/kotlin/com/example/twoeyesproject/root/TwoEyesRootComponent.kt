package com.example.twoeyesproject.root

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.router.stack.StackNavigation
import com.arkivanov.decompose.router.stack.childStack
import com.arkivanov.decompose.router.stack.pop
import com.arkivanov.decompose.router.stack.push
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.feed.DefaultFeedComponent
import com.example.twoeyesproject.feeddetail.DefaultFeedDetailComponent

class TwoEyesRootComponent(
    componentContext: ComponentContext,
) : RootComponent, ComponentContext by componentContext {

    private val navigation = StackNavigation<Config>()

    override val stack: Value<ChildStack<*, RootComponent.Child>> =
        childStack(
            source = navigation,
            serializer = Config.serializer(),
            initialConfiguration = Config.Feed,
            handleBackButton = true,
            childFactory = ::child,
        )

    private fun child(config: Config, componentContext: ComponentContext): RootComponent.Child =
        when (config) {
            is Config.Feed -> RootComponent.Child.Feed(
                DefaultFeedComponent(
                    componentContext = componentContext,
                    onFeedClick = { feedId ->
                        navigation.push(Config.FeedDetail(feedId))
                    },
                    onSearchClick = {
                        // navigation.push(Config.FeedSearch)
                    }
                )
            )
            is Config.FeedDetail -> RootComponent.Child.FeedDetail(
                DefaultFeedDetailComponent(
                    componentContext = componentContext,
                    onBack = { navigation.pop() }
                )
            )
        }

    override fun onBackClicked() {
        navigation.pop()
    }
}