package com.example.twoeyesproject

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Upload
import androidx.compose.material3.FabPosition
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.toRoute
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.AppDatabase
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.feed.FeedListViewModel
import com.example.twoeyesproject.ui.camera.PickImageScreen
import com.example.twoeyesproject.ui.camera.PickImageMergeScreen
import com.example.twoeyesproject.ui.feed.FeedScreen
import com.example.twoeyesproject.ui.upload.UploadCreateFeedView
import com.example.twoeyesproject.ui.upload.UploadScreen
import com.example.twoeyesproject.upload.UploadViewModel
import org.koin.compose.koinInject

private const val ROUTE_FEED    = "feed"
private const val ROUTE_UPLOAD  = "upload"
private const val ROUTE_CAMERA  = "camera"
private const val ROUTE_MERGE   = "merge/{uri1}/{uri2}"

@Composable
@Preview
fun App() {
    MaterialTheme {
        val navController = rememberNavController()
        AppScaffold(navController)
    }
}

@Composable
private fun AppScaffold(navController: NavHostController) {
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    // BottomNav와 FAB는 카메라/병합 화면에서 숨김
    val showBottomBar = currentRoute !in listOf(ROUTE_CAMERA, ROUTE_MERGE)
    val db: AppDatabase = koinInject()
    val apiClient: ApiClient = koinInject()

    Scaffold(
        bottomBar = {
            if (showBottomBar) {
                NavigationBar {
                    NavigationBarItem(
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
            if (showBottomBar) {
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
                    onFeedClick = { /* 상세 화면은 추후 구현 */ }
                )
            }

            composable(ROUTE_UPLOAD) {
                UploadScreen(
                    viewModel = UploadViewModel(db),
                    onNext = { navController.navigate(it) }
                )
            }

            composable<MergeResultEntity> { navBackStackEntry ->
                UploadCreateFeedView(navBackStackEntry.toRoute<MergeResultEntity>())
            }

            composable(ROUTE_CAMERA) {
                PickImageScreen(
                    onBack = { navController.popBackStack() },
                    onNext = { uri1, uri2 ->
                        val encoded1 = android.net.Uri.encode(uri1)
                        val encoded2 = android.net.Uri.encode(uri2)
                        navController.navigate("merge/$encoded1/$encoded2")
                    }
                )
            }

            composable(ROUTE_MERGE) { backStackEntry ->
                val uri1 = backStackEntry.arguments?.getString("uri1") ?: return@composable
                val uri2 = backStackEntry.arguments?.getString("uri2") ?: return@composable
                PickImageMergeScreen(
                    uri1String = android.net.Uri.decode(uri1),
                    uri2String = android.net.Uri.decode(uri2),
                    onConfirm = {
                        navController.popBackStack(ROUTE_FEED, inclusive = false)
                    },
                    onCancel = { navController.popBackStack() }
                )
            }
        }
    }
}
