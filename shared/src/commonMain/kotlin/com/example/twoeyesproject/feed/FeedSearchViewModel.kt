package com.example.twoeyesproject.feed

import com.example.twoeyesproject.TwoEyesException
import com.example.twoeyesproject.TwoEyesViewModel
import com.example.twoeyesproject.dependency.ApiClient
import io.ktor.client.plugins.ResponseException
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class FeedSearchViewModel(val apiClient: ApiClient) : TwoEyesViewModel() {
    private var _listMockData = MutableStateFlow<List<FeedItemModel>>(mutableListOf())
    val listData: StateFlow<List<FeedItemModel>>
        get() = _listMockData.asStateFlow()

    private var _featuredMockData = MutableStateFlow<List<FeedItemModel>>(mutableListOf())
    val featuredData: StateFlow<List<FeedItemModel>>
        get() = _featuredMockData.asStateFlow()

    var isLoading = MutableStateFlow(false)

    suspend fun searchFeeds(query: String, page: Int = 1) {
        isLoading.value = true
        try {
            val response = apiClient.searchFeeds(query, page)
            isLoading.value = false
            _listMockData.value = response.data.map { it.toFeedItemModel() }
        } catch (e: Exception) {
            isLoading.value = false
            emitFeedListNetworkException(e)
        }
    }

    suspend fun featuredFeeds() {
        isLoading.value = true
        try {
            val response = apiClient.featuredFeeds()
            isLoading.value = false
            _featuredMockData.value = response.data.map { it.toFeedItemModel() }
        } catch (e: Exception) {
            isLoading.value = false
            emitFeedListNetworkException(e)
        }
    }

    fun removeFeedResults() {
        _listMockData.value = mutableListOf()
    }
}

fun TwoEyesViewModel.emitFeedListNetworkException(exception: Exception) {
    if (exception is ResponseException) {
        emitError(TwoEyesException.Http(
            statusCode = exception.response.status.value,
            message = exception.message ?: "HTTP error",
            cause = exception,
        ))
    } else {
        emitError(TwoEyesException.Network(
            message = exception.message ?: "Network error",
            cause = exception,
        ))
    }
}