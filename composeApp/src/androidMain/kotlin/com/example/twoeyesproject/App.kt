package com.example.twoeyesproject

import android.net.Uri
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.QuestionMark
import androidx.compose.material.icons.filled.Upload
import androidx.compose.material.icons.outlined.AccountCircle
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FabPosition
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemColors
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarColors
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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalWindowInfo
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.room.Room
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.toRoute
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.AppDatabase
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.design.AppColors
import org.koin.dsl.module
import com.example.twoeyesproject.feed.FeedListViewModel
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.platformspecific.PlatformSecureStorage
import com.example.twoeyesproject.platformspecific.getGoogleUserData
import com.example.twoeyesproject.ui.camera.PickImageMergeScreen
import com.example.twoeyesproject.ui.camera.PickImageScreen
import com.example.twoeyesproject.ui.feed.FeedScreen
import com.example.twoeyesproject.ui.upload.UploadCreateFeedView
import com.example.twoeyesproject.ui.upload.UploadScreen
import com.example.twoeyesproject.upload.UploadViewModel
import org.koin.android.ext.koin.androidContext
import org.koin.compose.KoinApplicationPreview
import org.koin.compose.koinInject

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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AppScaffold(navController: NavHostController) {
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    // 피드·업로드 화면에서만 AppBar / BottomBar / FAB 표시
    val showChrome = currentRoute in listOf(ROUTE_FEED, ROUTE_UPLOAD)

    var isLoggedIn      by remember { mutableStateOf(false) }
    var showLoginSheet  by remember { mutableStateOf(false) }

    // 앱 시작 시 저장된 토큰으로 로그인 상태 확인
    LaunchedEffect(Unit) {
        isLoggedIn = PlatformSecureStorage().getGoogleUserData() != null
    }

    val database: AppDatabase = koinInject()
    val apiClient: ApiClient = koinInject()

    Scaffold(
        topBar = {
            if (showChrome) {
                TopAppBar(
                    title = { Text("") },
                    colors = TopAppBarColors(
                        containerColor = Color(AppColors.Surface),
                        titleContentColor = Color(AppColors.TextPrimary),
                        subtitleContentColor = Color(AppColors.TextSecondary),
                        scrolledContainerColor = Color(AppColors.Surface2),
                        navigationIconContentColor = Color(AppColors.Accent),
                        actionIconContentColor = Color(AppColors.Accent)
                    ),
                    actions = {
                        IconButton(
                            onClick = {
                                // 로그인됐을 때는 추후 프로필 화면 구현 시 분기
                                showLoginSheet = true
                            }
                        ) {
                            Box(contentAlignment = Alignment.TopEnd) {
                                Icon(
                                    imageVector = Icons.Filled.AccountCircle,
                                    contentDescription = if (isLoggedIn) "프로필" else "로그인",
                                    modifier = Modifier.size(48.dp),
                                    tint = Color(AppColors.Primary)
                                )
                                Icon(
                                    imageVector = if (isLoggedIn) Icons.Filled.Check
                                    else Icons.Filled.QuestionMark,
                                    contentDescription = null,
                                    modifier = Modifier.size(24.dp),
                                    tint = Color(AppColors.Accent)
                                )
                            }
                        }
                    }
                )
            }
        },
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
            if (showChrome) {
                FloatingActionButton(onClick = { navController.navigate(ROUTE_CAMERA) }) {
                    Icon(Icons.Default.Add, contentDescription = "카메라")
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
                    viewModel = FeedListViewModel(apiClient),
                    onFeedClick = { /* 상세 화면 추후 구현 */ }
                )
            }

            composable(ROUTE_UPLOAD) {
                UploadScreen(
                    viewModel = UploadViewModel(database),
                    onNext = { navController.navigate(it) }
                )
            }

            composable<MergeResultEntity> { backStackEntry ->
                UploadCreateFeedView(
                    viewModel = UploadViewModel(database),
                    entity = backStackEntry.toRoute<MergeResultEntity>()
                )
            }

            composable(ROUTE_CAMERA) {
                PickImageScreen(
                    onBack = { navController.popBackStack() },
                    onNext = { uri1, uri2 ->
                        val encoded1 = Uri.encode(uri1)
                        val encoded2 = Uri.encode(uri2)
                        navController.navigate("merge/$encoded1/$encoded2")
                    }
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

    // 로그인 바텀 시트 — 화면 절반 높이
    if (showLoginSheet) {
        val screenHeight = LocalWindowInfo.current.containerDpSize.height
        ModalBottomSheet(
            onDismissRequest = { showLoginSheet = false },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        ) {
            LoginScreen(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(screenHeight / 2),
                onLoginSuccess = {
                    isLoggedIn = true
                    showLoginSheet = false
                }
            )
        }
    }
}
