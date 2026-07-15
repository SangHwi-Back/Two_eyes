package com.example.twoeyesproject.dependency

import com.example.twoeyesproject.feed.FeedItemModel

object FeedMockData {

    val feedItemList: List<FeedItemModel> = listOf(
        FeedItemModel(
            feedId      = "feed-001",
            imageUrls   = listOf(
                "https://picsum.photos/seed/a1/600/600",
                "https://picsum.photos/seed/a2/600/600",
                "https://picsum.photos/seed/a3/600/600",
            ),
            likes       = 42,
            author      = "mock_user_1",
            description = "이미지 3장짜리 게시물입니다. 좌우로 스와이프해보세요.",
            showReply   = false,
            replyArray  = emptyList(),
            isUserLiked = false,
        ),
        FeedItemModel(
            feedId      = "feed-002",
            imageUrls   = listOf(
                "https://picsum.photos/seed/b1/600/600",
            ),
            likes       = 100,
            author      = "mock_user_2",
            description = "이미지 1장짜리 게시물입니다.",
            showReply   = false,
            replyArray  = emptyList(),
            isUserLiked = false,
        ),
        FeedItemModel(
            feedId      = "feed-003",
            imageUrls   = listOf(
                "https://picsum.photos/seed/c1/600/600",
                "https://picsum.photos/seed/c2/600/600",
            ),
            likes       = 7,
            author      = "mock_user_3",
            description = "이미지 2장짜리 게시물입니다.",
            showReply   = false,
            replyArray  = emptyList(),
            isUserLiked = false,
        ),
    )

    const val FeedList = """
{
    "data": [
        {
            "id": "feed-001",
            "content": "이미지 3장짜리 게시물입니다. 좌우로 스와이프해보세요.",
            "tags": ["travel", "photo"],
            "likeCount": 42,
            "isLiked": false,
            "user": { "id": "user-001", "name": "mock_user_1", "profileImage": null },
            "images": [
                { "id": "img-001", "url": "https://picsum.photos/seed/a1/600/600", "order": 0 },
                { "id": "img-002", "url": "https://picsum.photos/seed/a2/600/600", "order": 1 },
                { "id": "img-003", "url": "https://picsum.photos/seed/a3/600/600", "order": 2 }
            ],
            "createdAt": "2025-01-01T00:00:00Z",
            "updatedAt": "2025-01-01T00:00:00Z"
        },
        {
            "id": "feed-002",
            "content": "이미지 1장짜리 게시물입니다.",
            "tags": ["daily", "life"],
            "likeCount": 100,
            "isLiked": false,
            "user": { "id": "user-002", "name": "mock_user_2", "profileImage": null },
            "images": [
                { "id": "img-004", "url": "https://picsum.photos/seed/b1/600/600", "order": 0 }
            ],
            "createdAt": "2025-01-02T00:00:00Z",
            "updatedAt": "2025-01-02T00:00:00Z"
        },
        {
            "id": "feed-003",
            "content": "이미지 2장짜리 게시물입니다.",
            "tags": ["food", "cafe", "seoul"],
            "likeCount": 7,
            "isLiked": false,
            "user": { "id": "user-003", "name": "mock_user_3", "profileImage": null },
            "images": [
                { "id": "img-005", "url": "https://picsum.photos/seed/c1/600/600", "order": 0 },
                { "id": "img-006", "url": "https://picsum.photos/seed/c2/600/600", "order": 1 }
            ],
            "createdAt": "2025-01-03T00:00:00Z",
            "updatedAt": "2025-01-03T00:00:00Z"
        }
    ],
    "meta": {
        "total": 3,
        "page": 1,
        "limit": 10,
        "totalPages": 1
    }
}
"""

    const val CreatedFeed = """
{
    "id": "feed-new-001",
    "content": "Test upload content",
    "tags": ["test", "upload"],
    "likeCount": 0,
    "isLiked": false,
    "user": { "id": "user-test", "name": "test_user", "profileImage": null },
    "images": [
        { "id": "img-new-001", "url": "https://picsum.photos/seed/test/600/600", "order": 0 }
    ],
    "createdAt": "2025-01-04T00:00:00Z",
    "updatedAt": "2025-01-04T00:00:00Z"
}
"""
}