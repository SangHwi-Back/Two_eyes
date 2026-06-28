package com.example.twoeyesproject.feed

import com.example.twoeyesproject.TwoEyesException
import com.example.twoeyesproject.TwoEyesViewModel
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.FeedResponse
import com.example.twoeyesproject.dependency.LikeResponse
import io.ktor.client.plugins.ResponseException
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlin.collections.listOf

class FeedListViewModel(val apiClient: ApiClient) : TwoEyesViewModel() {
    private var _listMockData = MutableStateFlow<List<FeedItemModel>>(mutableListOf())
    val listData: StateFlow<List<FeedItemModel>>
        get() = _listMockData.asStateFlow()

    suspend fun getAllFeeds() {
        try {
            val response = apiClient.getFeed(1)
            _listMockData.value = response.data.map { it.toFeedItemModel() }
        } catch (_: Exception) {
            print("Server not ready yet.")
        }
    }

    suspend fun updateLike(like: Boolean, feedId: String): LikeResponse? {
        try {
            val response = apiClient.postLike(like, feedId)
            _listMockData.value.first { it.feedId == response.feedId }.isUserLiked = like
            return response
        } catch (e: ResponseException) {
            emitError(TwoEyesException.Http(
                statusCode = e.response.status.value,
                message = e.message ?: "HTTP error",
                cause = e,
            ))
            return null
        } catch (e: Exception) {
            emitError(TwoEyesException.Network(
                message = e.message ?: "Network error",
                cause = e,
            ))
            return null
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
