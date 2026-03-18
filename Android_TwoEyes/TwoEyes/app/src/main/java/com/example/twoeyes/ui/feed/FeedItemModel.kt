package com.example.twoeyes.ui.feed

import android.net.Uri
import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class FeedItemModel(
    val images: List<Uri>,
    val likes: Int,
    val author: String,
    val description: String,
    var showReply: Boolean,
) : Parcelable
