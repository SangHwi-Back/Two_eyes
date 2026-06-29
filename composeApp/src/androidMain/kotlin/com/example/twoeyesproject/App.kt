package com.example.twoeyesproject

import android.net.Uri
import android.view.View
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Upload
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FabPosition
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemColors
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalWindowInfo
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.toRoute
import androidx.room.Room
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.AppDatabase
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.di.AppLoginStatus
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.platformspecific.PlatformSecureStorage
import com.example.twoeyesproject.platformspecific.getGoogleUserData
import com.example.twoeyesproject.ui.camera.PickImageMergeScreen
import com.example.twoeyesproject.ui.camera.PickImageScreen
import com.example.twoeyesproject.ui.feed.FeedScreen
import com.example.twoeyesproject.ui.upload.UploadCreateFeedView
import com.example.twoeyesproject.ui.upload.UploadScreen
import org.koin.android.ext.koin.androidContext
import org.koin.compose.KoinApplicationPreview
import org.koin.compose.koinInject
import org.koin.dsl.module

private const val ROUTE_FEED   = "feed"
private const val ROUTE_UPLOAD = "upload"
private const val ROUTE_CAMERA = "camera"
private const val ROUTE_MERGE  = "merge/{uri1}/{uri2}"

@Composable
fun App() {
    MaterialTheme {
        AppScaffold(rememberNavController())
    }
}

// Preview 전용 모듈 — 파일 기반 Room DB 대신 인메모리 DB 사용
// (Preview 환경에서는 context.getDatabasePath() 가 null 을 반환해 NPE 발생)
private val previewModule = module {
    factory { ImageDecoder() }
    single {
        Room.inMemoryDatabaseBuilder(androidContext(), AppDatabase::class.java)
            .allowMainThreadQueries()
            .build()
    }
    single { ApiClient() }
}

@Preview(showBackground = true)
@Composable
private fun AppPreview() {
    val context = LocalContext.current

    KoinApplicationPreview(application = {
        androidContext(context)
        modules(previewModule)
    }) {
        MaterialTheme {
            AppScaffold(rememberNavController())
        }
    }
}
data class TopAppBarData(
    val title: String,
    val action: @Composable () -> Unit,
    val visibility: Int = View.VISIBLE,
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AppScaffold(navController: NavHostController) {
    val loginStatus = koinInject<AppLoginStatus>()

    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val error             by AppErrorBus.error.collectAsStateWithLifecycle()
    var topAppBarData     by remember { mutableStateOf(TopAppBarData("", { })) }

    // 피드·업로드 화면에서만 AppBar / BottomBar / FAB 표시
    val currentRoute = navBackStackEntry?.destination?.route
    val showChrome = currentRoute in listOf(ROUTE_FEED, ROUTE_UPLOAD)

    // 앱 시작 시 저장된 토큰으로 로그인 상태 확인
    LaunchedEffect(Unit) {
        loginStatus.isLoggedIn = PlatformSecureStorage().getGoogleUserData() != null
    }

    Scaffold(
        topBar = { DynamicTopAppBar(topAppBarData) },
        bottomBar = {
            if (showChrome) {
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
                        selected = currentRoute == ROUTE_FEED,
                        onClick = {
                            navController.navigate(ROUTE_FEED) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        icon = { Icon(Icons.Default.Home, contentDescription = "피드") },
                        label = { Text("피드") }
                    )
                    NavigationBarItem(
                        colors = navigationBarItemColors,
                        selected = currentRoute == ROUTE_UPLOAD,
                        onClick = {
                            navController.navigate(ROUTE_UPLOAD) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        icon = { Icon(Icons.Default.Upload, contentDescription = "업로드") },
                        label = { Text("업로드") }
                    )
                }
            }
        },
        floatingActionButtonPosition = FabPosition.Center,
        floatingActionButton = {
            val shape = RoundedCornerShape(AppConstants.CARD_CORNER_RADIUS)
            if (showChrome) {
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .graphicsLayer { translationY = 60.dp.toPx() }
                        .size(56.dp)
                        .background(Color(AppColors.Surface2), shape)
                        .border(1.5.dp, Color.White, shape)
                        .clickable { navController.navigate(ROUTE_CAMERA) }
                ) {
                    Icon(
                        Icons.Default.Add,
                        contentDescription = "카메라",
                        tint = Color.White
                    )
                }
            }
        },
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = ROUTE_FEED,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(ROUTE_FEED) {
                FeedScreen(
                    onFeedClick = {},
                    topAppBarDataChange = { topAppBarData = it }
                )
            }

            composable(ROUTE_UPLOAD) {
                UploadScreen(
                    onNext = { navController.navigate(it) },
                    topAppBarDataChange = { topAppBarData = it }
                )
            }

            composable<MergeResultEntity> { backStackEntry ->
                UploadCreateFeedView(entity = backStackEntry.toRoute<MergeResultEntity>())
            }

            composable(ROUTE_CAMERA) {
                PickImageScreen(
                    onBack = { navController.popBackStack() },
                    onNext = { uri1, uri2 ->
                        val encoded1 = Uri.encode(uri1)
                        val encoded2 = Uri.encode(uri2)
                        navController.navigate("merge/$encoded1/$encoded2")
                    },
                    topAppBarDataChange = { topAppBarData = it }
                )
            }

            composable(ROUTE_MERGE) { backStackEntry ->
                val uri1 = backStackEntry.arguments?.getString("uri1") ?: return@composable
                val uri2 = backStackEntry.arguments?.getString("uri2") ?: return@composable
                PickImageMergeScreen(
                    uri1String = Uri.decode(uri1),
                    uri2String = Uri.decode(uri2),
                    onConfirm = { navController.popBackStack(ROUTE_FEED, inclusive = false) },
                    onCancel  = { navController.popBackStack() }
                )
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
