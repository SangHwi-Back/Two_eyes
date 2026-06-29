package com.example.twoeyesproject.ui.feed

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.Comment
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.QuestionMark
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.Share
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonColors
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil3.compose.AsyncImage
import com.example.twoeyesproject.TopAppBarData
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.feed.FeedItemModel
import com.example.twoeyesproject.feed.FeedListViewModel
import com.example.twoeyesproject.platformspecific.PlatformSecureStorage
import com.example.twoeyesproject.platformspecific.getGoogleUserData
import kotlinx.coroutines.launch
import org.koin.androidx.compose.koinViewModel

enum class FeedScreenTapType {
    LIKE, COMMENT, SHARE, FEED
}

@Composable
fun FeedScreen(
    viewModel: FeedListViewModel = koinViewModel(),
    onFeedClick: (FeedItemModel) -> Unit,
    onSearchClick: () -> Unit = {},
    topAppBarDataChange: ((TopAppBarData) -> Unit)? = null,
) {
    val items by viewModel.listData.collectAsStateWithLifecycle()

    val scope = rememberCoroutineScope()

    LaunchedEffect(Unit) {
        val isLoggedIn = PlatformSecureStorage().getGoogleUserData() != null

        if (isLoggedIn)
            viewModel.getAllFeeds()
    }

    SideEffect {
        topAppBarDataChange?.invoke(TopAppBarData("", {
            IconButton(onClick = onSearchClick) {
                Icon(
                    imageVector = Icons.Outlined.Search,
                    contentDescription = "검색",
                )
            }
            IconButton(
                onClick = {
                    // 로그인됐을 때는 추후 프로필 화면 구현 시 분기
                }
            ) {
                Box(contentAlignment = Alignment.TopEnd) {
                    Icon(
                        imageVector = Icons.Filled.AccountCircle,
                        contentDescription = "로그인",
                        modifier = Modifier.size(48.dp),
                        tint = Color(AppColors.Primary)
                    )
                    Icon(
                        imageVector = Icons.Filled.QuestionMark,
                        contentDescription = null,
                        modifier = Modifier.size(24.dp),
                        tint = Color(AppColors.Accent)
                    )
                }
            }
        }))
    }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(AppColors.Background))
    ) {
        items(items) { item ->
            FeedItemCard(item = item, onClick = {
                scope.launch {
                    when (it) {
                        FeedScreenTapType.LIKE -> viewModel.updateLike(true, "")
                        FeedScreenTapType.COMMENT -> viewModel.updateLike(true, "")
                        FeedScreenTapType.SHARE -> viewModel.updateLike(true, "")
                        else -> onFeedClick(item)
                    }
                }
            })
            HorizontalDivider()
        }
    }
}

@Composable
private fun FeedItemCard(item: FeedItemModel, onClick: (FeedScreenTapType) -> Unit) {
    val pagerState = rememberPagerState { item.imageUrls.size }
    var showReply by remember { mutableStateOf(item.showReply) }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(color = Color(AppColors.Background))
            .clickable {
                onClick(FeedScreenTapType.FEED)
            }
    ) {
        // 이미지 페이저 (ViewPager2 대응)
        HorizontalPager(
            state = pagerState,
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
        ) { page ->
            AsyncImage(
                model = item.imageUrls[page].toUri(),
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize()
            )
        }

        // 페이지 인디케이터 (이미지가 2장 이상일 때만 표시)
        if (item.imageUrls.size > 1) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 8.dp),
                horizontalArrangement = Arrangement.Center
            ) {
                repeat(item.imageUrls.size) { index ->
                    val isSelected = pagerState.currentPage == index
                    Box(
                        modifier = Modifier
                            .padding(horizontal = 4.dp)
                            .size(if (isSelected) 8.dp else 6.dp)
                            .background(
                                color = if (isSelected)
                                    Color(AppColors.Background)
                                else
                                    Color(AppColors.Surface).copy(0.3f),
                                shape = CircleShape
                            )
                    )
                }
            }
        }

        // 좋아요 / 댓글 / 공유 버튼
        Row(modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)) {
            val buttonColor = IconButtonColors(
                contentColor = Color(AppColors.Accent),
                containerColor = Color.Transparent,
                disabledContainerColor = Color.Transparent,
                disabledContentColor = Color.Transparent
            )
            IconButton(colors = buttonColor, onClick = {
                onClick(FeedScreenTapType.LIKE)
            }) {
                Icon(Icons.Outlined.FavoriteBorder, contentDescription = "좋아요")
            }
            IconButton(colors = buttonColor, onClick = {
                onClick(FeedScreenTapType.COMMENT)
            }) {
                Icon(Icons.AutoMirrored.Outlined.Comment, contentDescription = "댓글")
            }
            IconButton(colors = buttonColor, onClick = {
                onClick(FeedScreenTapType.SHARE)
            }) {
                Icon(Icons.Outlined.Share, contentDescription = "공유")
            }
        }

        // 작성자 + 설명
        Row(modifier = Modifier.padding(horizontal = 8.dp)) {
            Text(
                text = item.author,
                color = Color(AppColors.TextPrimary),
                style = MaterialTheme.typography.labelLarge,
                modifier = Modifier.padding(end = 8.dp)
            )
            Text(
                text = item.description,
                color = Color(AppColors.TextPrimary),
                style = MaterialTheme.typography.bodyMedium,
            )
        }

        // 댓글 토글 버튼 (showReply)
        TextButton(
            onClick = {
                showReply = !showReply
                item.showReply = showReply
            },
            modifier = Modifier.padding(start = 4.dp)
        ) {
            Text(if (showReply) "댓글 숨기기" else "댓글 보기")
        }

        if (showReply) {
            Text(
                text = "댓글 영역",
                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                style = MaterialTheme.typography.bodySmall,
                color = Color(AppColors.Surface)
            )
        }

        Spacer(modifier = Modifier.height(8.dp))
    }
}
