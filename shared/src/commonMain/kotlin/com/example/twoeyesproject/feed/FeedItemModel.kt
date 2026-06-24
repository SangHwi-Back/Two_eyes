package com.example.twoeyesproject.feed

data class FeedItemModel(
    val feedId: String,
    val imageUrls: List<String>,
    val likes: Int,
    val author: String,
    val description: String,
    var showReply: Boolean,
    var replyArray: List<FeedItemReplyModel>,
    var isUserLiked: Boolean
)

data class FeedItemReplyModel(
    val feedId: String,
    val replyId: String,
    val author: String,
    val description: String,
)