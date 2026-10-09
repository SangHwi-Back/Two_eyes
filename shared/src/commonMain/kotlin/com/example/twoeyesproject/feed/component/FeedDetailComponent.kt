package com.example.twoeyesproject.feeddetail

import com.example.twoeyesproject.feed.FeedItemModel
import kotlinx.coroutines.flow.StateFlow

interface FeedDetailComponent {
    val feedItem: StateFlow<FeedItemModel?>
    fun onBackClick()
    fun onLikeClick()
}