package com.example.twoeyesproject

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.QuestionMark
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.arkivanov.decompose.extensions.compose.stack.Children
import com.arkivanov.decompose.extensions.compose.stack.animation.stackAnimation
import com.arkivanov.decompose.extensions.compose.subscribeAsState
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.root.RootComponent
import com.example.twoeyesproject.ui.feed.FeedContent
import com.example.twoeyesproject.ui.feed.FeedDetailContent

@Composable
fun RootContent(
    component: RootComponent,
    onSearchClick: () -> Unit,
    onTopAppBarDataChange: (TopAppBarData) -> Unit,
) {
    val stack by component.stack.subscribeAsState()
    val activeChild = stack.active.instance

    LaunchedEffect(activeChild) {
        onTopAppBarDataChange(topAppBarDataFor(activeChild, onSearchClick))
    }

    Children(
        stack = stack,
        animation = stackAnimation(),
    ) {
        when (val child = it.instance) {
            is RootComponent.Child.Feed -> FeedContent(component = child.component)
            is RootComponent.Child.FeedDetail -> FeedDetailContent(component = child.component)
        }
    }
}

private fun topAppBarDataFor(child: RootComponent.Child, onSearchClick: () -> Unit): TopAppBarData =
    when (child) {
        is RootComponent.Child.Feed -> TopAppBarData(
            title = "",
            action = {
                IconButton(onClick = onSearchClick) {
                    Icon(Icons.Outlined.Search, contentDescription = "검색")
                }
                // 프로필 아이콘 등
            }
        )
        is RootComponent.Child.FeedDetail -> TopAppBarData(
            title = "",
            backButton = TopAppBarBackButton.Functionable(child.component::onBackClick),
            action = {
                IconButton(onClick = {
                    // TODO: 추후 프로필 화면 구현 시
                }) {
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
            },
        )
    }
