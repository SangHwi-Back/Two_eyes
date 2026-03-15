package com.example.twoeyes.ui.feed

import android.net.Uri

data class FeedItemModel(
    val images: List<Uri>,
    val likes: Int,
    val author: String,
    val description: String,
    var showReply: Boolean,
)
