package com.example.twoeyesproject.feed

import com.example.twoeyesproject.platformspecific.Parcelize
import com.example.twoeyesproject.platformspecific.PlatformParcelable
import com.example.twoeyesproject.platformspecific.PlatformUri

@Parcelize
data class FeedItemModel(
    val images: List<PlatformUri>,
    val likes: Int,
    val author: String,
    val description: String,
    var showReply: Boolean,
) : PlatformParcelable