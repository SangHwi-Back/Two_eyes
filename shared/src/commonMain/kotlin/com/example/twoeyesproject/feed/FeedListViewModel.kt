package com.example.twoeyesproject.feed

import com.example.twoeyesproject.TwoEyesViewModel
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.FeedMockData
import com.example.twoeyesproject.dependency.FeedResponse
import com.example.twoeyesproject.dependency.LikeResponse
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class FeedListViewModel(val apiClient: ApiClient) : TwoEyesViewModel() {
    private var _listMockData = MutableStateFlow<List<FeedItemModel>>(
        FeedMockData.feedItemList.toMutableList()
    )
    val listData: StateFlow<List<FeedItemModel>>
        get() = _listMockData.asStateFlow()

    var isLoading = MutableStateFlow(false)

    suspend fun getAllFeeds(page: Int = 1) {
        isLoading.value = true
        try {
            val response = apiClient.getFeed(page)
            isLoading.value = false
            _listMockData.value = response.data.map { it.toFeedItemModel() }
        } catch (e: Exception) {
            isLoading.value = false
            emitFeedListNetworkException(e)
        }
    }

    suspend fun updateLike(like: Boolean, feedId: String): LikeResponse? {
        isLoading.value = true
        try {
            val response = apiClient.postLike(like, feedId)
            isLoading.value = false
            _listMockData.value.first { it.feedId == response.feedId }.isUserLiked = like
            return response
        } catch (e: Exception) {
            isLoading.value = false
            emitFeedListNetworkException(e)
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
