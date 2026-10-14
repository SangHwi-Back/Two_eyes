package com.example.twoeyesproject

import androidx.compose.animation.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBackIos
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.navigation.compose.rememberNavController
import com.example.twoeyesproject.design.AppColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DynamicTopAppBar(data: TopAppBarData ) {
    val navController = rememberNavController()
    AnimatedVisibility(
        visible = data.visible,
        enter = slideInVertically(initialOffsetY = { -it }) + fadeIn(),
        exit = slideOutVertically(targetOffsetY = { -it }) + fadeOut()
    ) {
        TopAppBar(
            title = { Text(data.title) },
            navigationIcon = {
                when (data.backButton) {
                    TopAppBarBackButton.Invisible -> Unit
                    TopAppBarBackButton.Common ->
                        IconButton({
                            navController.popBackStack()
                        }) {
                            Icons.AutoMirrored.Outlined.ArrowBackIos
                        }
                    is TopAppBarBackButton.Functionable ->
                        IconButton(data.backButton.onBackButtonTapped) {
                            Icons.AutoMirrored.Outlined.ArrowBackIos
                        }
                    is TopAppBarBackButton.Custom ->
                        IconButton(data.backButton.onBackButtonTapped) {
                            data.backButton.icon
                        }
                }
            },
            colors = TopAppBarColors(
                containerColor = Color(AppColors.Surface),
                titleContentColor = Color(AppColors.TextPrimary),
                subtitleContentColor = Color(AppColors.TextSecondary),
                scrolledContainerColor = Color(AppColors.Surface2),
                navigationIconContentColor = Color(AppColors.Accent),
                actionIconContentColor = Color(AppColors.Accent)
            ),
            actions = {
                data.action()
            }
        )
    }
}

data class TopAppBarData(
    val title: String,
    val action: @Composable () -> Unit,
    val visible: Boolean = true,
    val backButton: TopAppBarBackButton = TopAppBarBackButton.Invisible
)

sealed class TopAppBarBackButton {
    data object Invisible : TopAppBarBackButton()
    data object Common : TopAppBarBackButton()
    data class Functionable(val onBackButtonTapped: () -> Unit) : TopAppBarBackButton()
    data class Custom(
        val icon: @Composable () -> Unit,
        val onBackButtonTapped: () -> Unit
    ) : TopAppBarBackButton()
}