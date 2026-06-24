package com.example.twoeyesproject.feed

import androidx.lifecycle.ViewModel
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.FeedResponse
import io.ktor.http.HttpStatusCode
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlin.collections.listOf

class FeedListViewModel(val apiClient: ApiClient): ViewModel() {
    private var _listMockData = MutableStateFlow<List<FeedItemModel>>(mutableListOf())
    val listData = _listMockData.asStateFlow()

    suspend fun getAllFeeds() {
        try {
            val response = apiClient.getFeed(1)
            _listMockData.value = response.data.map { it.toFeedItemModel() }
        } catch (_: Exception) {
            print("Server not ready yet.")
        }
    }

    suspend fun updateLike(like: Boolean, feedId: String) {
        try {
            val response = apiClient.postLike(like, feedId)

            if (response.status != HttpStatusCode.OK) return

            try {
                _listMockData.value.first { it.feedId == feedId }.isUserLiked = like
            } catch (e: NoSuchElementException) {
                print("Error! $e")
            }
        } catch (_: Exception) {
            print("Server not ready yet.")
        }
    }
}

fun FeedResponse.Data.toFeedItemModel() : FeedItemModel =
    FeedItemModel(
        feedId = id,
        imageUrls = images.map { it.url },
        likes = likeCount,
        author = user.name.orEmpty(),
        description = content.orEmpty(),
        showReply = false,
        replyArray = listOf(),
        isUserLiked = isLiked
    )