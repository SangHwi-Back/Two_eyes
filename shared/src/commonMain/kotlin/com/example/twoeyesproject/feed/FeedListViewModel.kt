package com.example.twoeyesproject.feed

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.FeedResponse
import io.ktor.client.statement.HttpResponse
import io.ktor.http.HttpStatusCode
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlin.collections.listOf
import kotlin.uuid.Uuid

class FeedListViewModel(val apiClient: ApiClient): ViewModel() {
    var mergeEntities = MutableStateFlow<List<FeedResponse.Data>>(listOf())
    private var _listMockData = MutableStateFlow(listOf(
        FeedItemModel(
            feedId = Uuid.random().toString(),
            imageUrls = listOf(
                "https://picsum.photos/seed/a1/600/600",
                "https://picsum.photos/seed/a2/600/600",
                "https://picsum.photos/seed/a3/600/600",
            ),
            likes = 42,
            author = "mock_user_1",
            description = "이미지 3장짜리 게시물입니다. 좌우로 스와이프해보세요.",
            showReply = false,
            replyArray = listOf()
        ).apply {
            replyArray = listOf(
                FeedItemReplyModel(
                    feedId = feedId,
                    replyId = Uuid.random().toString(),
                    author = "mock_user_2",
                    description = "이미지 3개 코멘트 1"
                ),
                FeedItemReplyModel(
                    feedId = feedId,
                    replyId = Uuid.random().toString(),
                    author = "mock_user_3",
                    description = "이미지 3개 코멘트 2"
                ),
                FeedItemReplyModel(
                    feedId = feedId,
                    replyId = Uuid.random().toString(),
                    author = "mock_user_2",
                    description = "이미지 3개 코멘트 333333333333333333333333333333333"
                )
            )
        },
        FeedItemModel(
            feedId = Uuid.random().toString(),
            imageUrls = listOf(
                "https://picsum.photos/seed/b1/600/600",
            ),
            likes = 100,
            author = "mock_user_2",
            description = "이미지 1장짜리 게시물입니다.",
            showReply = false,
            replyArray = listOf()
        ),
        FeedItemModel(
            feedId = Uuid.random().toString(),
            imageUrls = listOf(
                "https://picsum.photos/seed/c1/600/600",
                "https://picsum.photos/seed/c2/600/600",
            ),
            likes = 7,
            author = "mock_user_3",
            description = "이미지 2장짜리 게시물입니다.",
            showReply = false,
            replyArray = listOf()
        ),
    ))
    val listData = _listMockData.asStateFlow()

    init {
        getAllFeeds()
    }
    fun getAllFeeds() {
        viewModelScope.launch {
            var mutableData = mutableListOf<FeedResponse.Data>()
            try {
                val response = apiClient.getFeed("", 1)
                mutableData = response.data.toMutableList()
            } catch (_: Exception) {
                print("Server not ready yet.")
            }

            mergeEntities.value = mutableData
        }
    }

    fun updateLike(like: Boolean, feedId: String) {
        viewModelScope.launch {
            var response: HttpResponse? = null
            try {
                response = apiClient.postLike("", like, feedId)
            } catch (_: Exception) {
                print("Server not ready yet.")
            }

            if (response != null && response.status == HttpStatusCode.OK) {
                mergeEntities.value.indexOfFirst { it.id == feedId }.let { index ->
                    if (index > -1) {
                        val entities = mergeEntities.value.toMutableList()
                        entities[index] = entities[index].copy(isLiked = like)
                        mergeEntities.value = entities
                    }
                }
            }
        }
    }
}

