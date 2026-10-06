package com.example.twoeyesproject

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.compose.rememberLifecycleOwner
import androidx.navigation.compose.rememberNavController
import androidx.room.Room
import com.arkivanov.decompose.DefaultComponentContext
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.dependency.AppDatabase
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.root.RootComponent
import com.example.twoeyesproject.root.TwoEyesRootComponent
import org.koin.android.ext.koin.androidContext
import org.koin.compose.KoinApplicationPreview
import org.koin.dsl.module

private val TwoEyesColorScheme = darkColorScheme(
    background       = Color(AppColors.Background),
    surface          = Color(AppColors.Surface),
    surfaceVariant   = Color(AppColors.Surface2),
    primary          = Color(AppColors.Primary),
    secondary        = Color(AppColors.Secondary),
    error            = Color(AppColors.Error),
    onBackground     = Color(AppColors.TextPrimary),
    onSurface        = Color(AppColors.TextPrimary),
    onSurfaceVariant = Color(AppColors.TextSecondary),
    onPrimary        = Color(AppColors.TextPrimary),
    outline          = Color(AppColors.Divider),
)

@Composable
fun App(rootComponent: RootComponent) {
    MaterialTheme(colorScheme = TwoEyesColorScheme) {
        AppScaffold(
            rememberNavController(),
            rootComponent
        )
    }
}

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
        MaterialTheme(colorScheme = TwoEyesColorScheme) {
            AppScaffold(
                rememberNavController(),
                TwoEyesRootComponent(
                    componentContext = DefaultComponentContext(
                        lifecycle = rememberLifecycleOwner().lifecycle
                    )
                )
            )
        }
    }
}