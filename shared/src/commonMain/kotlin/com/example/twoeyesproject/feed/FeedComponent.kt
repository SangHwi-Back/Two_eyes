package com.example.twoeyesproject.feed

import kotlinx.coroutines.flow.StateFlow

interface FeedComponent {
    val items: StateFlow<List<FeedItemModel>>

    fun onFeedClick(feedId: String)
    fun onSearchClick()
    fun onLikeClick(feedId: String)
}