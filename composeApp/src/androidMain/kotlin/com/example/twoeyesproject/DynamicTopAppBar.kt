package com.example.twoeyesproject

import android.view.View
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarColors
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.example.twoeyesproject.design.AppColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DynamicTopAppBar(data: TopAppBarData ) {
    AnimatedVisibility(
        visible = data.visibility == View.VISIBLE,
        enter = slideInVertically(initialOffsetY = { -it }) + fadeIn(),
        exit = slideOutVertically(targetOffsetY = { -it }) + fadeOut()
    ) {
        TopAppBar(
            title = { Text(data.title) },
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