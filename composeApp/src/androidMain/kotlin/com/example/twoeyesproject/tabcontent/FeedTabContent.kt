package com.example.twoeyesproject.tabcontent

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import com.arkivanov.decompose.extensions.compose.subscribeAsState
import com.example.twoeyesproject.TopAppBarData
import com.example.twoeyesproject.root.RootComponent
import com.example.twoeyesproject.root.feed.FeedTabComponent
import com.example.twoeyesproject.ui.feed.FeedDetailContent
import com.example.twoeyesproject.ui.feed.FeedScreen
import com.example.twoeyesproject.ui.feed.FeedSearchScreen

@Composable
fun FeedTabContent(
    rootComponent: RootComponent,
    topAppBarDataChange: (TopAppBarData) -> Unit = {},
) {
    val stack by rootComponent.feedTab.stack.subscribeAsState()
    when (val instance = stack.active.instance) {
        is FeedTabComponent.Child.Feed ->
            FeedScreen(
                component = instance.component,
                onTapShowLogin = {
                    rootComponent.overlayComponent.showLogin()
                },
                topAppBarDataChange = topAppBarDataChange
            )
        is FeedTabComponent.Child.FeedDetail ->
            FeedDetailContent(instance.component)
        is FeedTabComponent.Child.FeedSearch ->
            FeedSearchScreen(
                instance.component,
                topAppBarDataChange = topAppBarDataChange,
            )
    }
}