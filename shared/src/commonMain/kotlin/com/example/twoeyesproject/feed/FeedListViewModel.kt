package com.example.twoeyesproject.feed

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

class FeedListViewModel: ViewModel() {
    private var _listMockData = MutableStateFlow(listOf(
        FeedItemModel(
            imageUrls = listOf(
                "https://picsum.photos/seed/a1/600/600",
                "https://picsum.photos/seed/a2/600/600",
                "https://picsum.photos/seed/a3/600/600",
            ),
            likes = 42,
            author = "mock_user_1",
            description = "이미지 3장짜리 게시물입니다. 좌우로 스와이프해보세요.",
            showReply = false,
        ),
        FeedItemModel(
            imageUrls = listOf(
                "https://picsum.photos/seed/b1/600/600",
            ),
            likes = 100,
            author = "mock_user_2",
            description = "이미지 1장짜리 게시물입니다.",
            showReply = false,
        ),
        FeedItemModel(
            imageUrls = listOf(
                "https://picsum.photos/seed/c1/600/600",
                "https://picsum.photos/seed/c2/600/600",
            ),
            likes = 7,
            author = "mock_user_3",
            description = "이미지 2장짜리 게시물입니다.",
            showReply = false,
        ),
    ))
    val listData = _listMockData.asStateFlow()
}

