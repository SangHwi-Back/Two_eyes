package com.example.twoeyesproject.tabcontent

import androidx.compose.foundation.layout.Box
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import com.arkivanov.decompose.extensions.compose.subscribeAsState
import com.example.twoeyesproject.FeedSearchScreen
import com.example.twoeyesproject.root.feed.FeedTabComponent
import com.example.twoeyesproject.ui.feed.FeedDetailContent
import com.example.twoeyesproject.ui.feed.FeedScreen

@Composable
fun FeedTabContent(
    component: FeedTabComponent
) {
    val stack by component.stack.subscribeAsState()
    when (val instance = stack.active.instance) {
        is FeedTabComponent.Child.Feed ->
            FeedScreen(onFeedClick = { })
        is FeedTabComponent.Child.FeedDetail ->
            FeedDetailContent(instance.component)
        is FeedTabComponent.Child.FeedSearch ->
            FeedSearchScreen(
                onBackButtonClick = {
                    instance.component.onBackClick()
                },
                topAppBarDataChange = {

                },
            )
    }
}