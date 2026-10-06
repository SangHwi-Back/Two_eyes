package com.example.twoeyesproject.ui.feed

import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import com.example.twoeyesproject.feed.FeedComponent

@Composable
fun FeedContent(component: FeedComponent) {
    val items by component.items.collectAsState()

    LazyColumn {
        items(items) { item ->
            FeedItemCard(
                item = item,
                onClick = { type ->
                    when (type) {
                        FeedScreenTapType.LIKE -> component.onLikeClick(item.feedId)
                        FeedScreenTapType.FEED -> component.onLikeClick(item.feedId)
                        else -> return@FeedItemCard
                    }
                }
            )
        }
    }
}