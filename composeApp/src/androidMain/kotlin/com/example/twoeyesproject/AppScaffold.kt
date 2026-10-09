package com.example.twoeyesproject

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Upload
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalWindowInfo
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.arkivanov.decompose.extensions.compose.subscribeAsState
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.di.AppLoginStatus
import com.example.twoeyesproject.platformspecific.PlatformSecureStorage
import com.example.twoeyesproject.platformspecific.getGoogleUserData
import com.example.twoeyesproject.root.Config
import com.example.twoeyesproject.root.RootComponent
import com.example.twoeyesproject.tabcontent.FeedTabContent
import com.example.twoeyesproject.tabcontent.PickImageTabContent
import com.example.twoeyesproject.tabcontent.UploadTabContent
import org.koin.compose.koinInject

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppScaffold(rootComponent: RootComponent) {
    val loginStatus = koinInject<AppLoginStatus>()

    BackHandler(enabled = true) { rootComponent.onBackClicked() }

    val error             by AppErrorBus.error.collectAsStateWithLifecycle()
    var topAppBarData     by remember { mutableStateOf(TopAppBarData("", { })) }

    // 피드·업로드 화면에서만 AppBar / BottomBar / FAB 표시
    // 단, 피드 탭 안에서 Decompose가 FeedDetail로 전환된 상태라면 chrome을 숨긴다.
    val activeTab by rootComponent.active.subscribeAsState()

    // 앱 시작 시 저장된 토큰으로 로그인 상태 확인
    LaunchedEffect(Unit) {
        loginStatus.isLoggedIn = PlatformSecureStorage().getGoogleUserData() != null
    }

    Scaffold(
        topBar = { DynamicTopAppBar(topAppBarData) },
        bottomBar = {
            val navigationBarItemColors = NavigationBarItemColors(
                selectedIconColor = Color(AppColors.Surface),
                selectedTextColor = Color(AppColors.TextPrimary),
                selectedIndicatorColor = Color(AppColors.Accent),
                unselectedIconColor = Color(AppColors.Surface2),
                unselectedTextColor = Color(AppColors.TextSecondary),
                disabledIconColor = Color(AppColors.TextDisabled),
                disabledTextColor = Color(AppColors.TextDisabled)
            )

            NavigationBar(
                containerColor = Color(AppColors.Surface),
                contentColor = Color(AppColors.Surface2),
            ) {
                NavigationBarItem(
                    colors = navigationBarItemColors,
                    selected = activeTab == Config.Feed,
                    onClick = {
                        rootComponent.onTabButtonClicked(Config.Feed)
                    },
                    icon = { Icon(Icons.Default.Home, contentDescription = "피드") },
                    label = { Text("피드") }
                )
                NavigationBarItem(
                    colors = navigationBarItemColors,
                    selected = activeTab == Config.Upload,
                    onClick = {
                        rootComponent.onTabButtonClicked(Config.Upload)
                    },
                    icon = { Icon(Icons.Default.Upload, contentDescription = "업로드") },
                    label = { Text("업로드") }
                )
            }
        },
        floatingActionButtonPosition = FabPosition.Center,
        floatingActionButton = {
            val shape = RoundedCornerShape(AppConstants.CARD_CORNER_RADIUS)
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .graphicsLayer { translationY = 60.dp.toPx() }
                    .size(56.dp)
                    .background(Color(AppColors.Surface2), shape)
                    .border(1.5.dp, Color.White, shape)
                    .clickable {
                        rootComponent.onTabButtonClicked(Config.PickImage)
                    }
            ) {
                Icon(
                    Icons.Default.Add,
                    contentDescription = "카메라",
                    tint = Color.White
                )
            }
        },
    ) { innerPadding ->
        Box(modifier = Modifier.padding(innerPadding)) {
            when (activeTab) {
                Config.Feed -> FeedTabContent(rootComponent.feedTab)
                Config.Upload -> UploadTabContent(rootComponent.uploadTab)
                Config.PickImage -> PickImageTabContent(rootComponent.pickImageTab)
            }
        }
    }

    // 에러 알럿 — AppErrorBus 에서 수신
    error?.let { userError ->
        AlertDialog(
            onDismissRequest = { AppErrorBus.clear() },
            title = { Text(userError.title) },
            text = { Text(userError.message) },
            confirmButton = {
                TextButton(onClick = { AppErrorBus.clear() }) { Text("확인") }
            }
        )
    }

    // 로그인 바텀 시트 — 화면 절반 높이
    if (loginStatus.showLoginSheet) {
        val screenHeight = LocalWindowInfo.current.containerDpSize.height
        ModalBottomSheet(
            onDismissRequest = { loginStatus.showLoginSheet = false },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        ) {
            LoginScreen(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(screenHeight / 2),
                onLoginSuccess = {
                    loginStatus.isLoggedIn = true
                    loginStatus.showLoginSheet = false
                }
            )
        }
    }
}