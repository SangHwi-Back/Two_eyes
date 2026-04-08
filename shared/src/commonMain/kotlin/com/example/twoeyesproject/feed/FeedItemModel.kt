package com.example.twoeyesproject.feed

data class FeedItemModel(
    val imageUrls: List<String>,
    val likes: Int,
    val author: String,
    val description: String,
    var showReply: Boolean,
)