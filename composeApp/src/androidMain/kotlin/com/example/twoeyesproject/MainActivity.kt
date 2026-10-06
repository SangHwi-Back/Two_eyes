package com.example.twoeyesproject

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.compose.rememberLifecycleOwner
import com.arkivanov.decompose.DefaultComponentContext
import com.arkivanov.decompose.defaultComponentContext
import com.example.twoeyesproject.root.TwoEyesRootComponent

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        val rootComponent = TwoEyesRootComponent(
            componentContext = defaultComponentContext()
        )

        setContent {
            App(rootComponent)
        }
    }
}

@Preview
@Composable
fun AppAndroidPreview() {
    App(TwoEyesRootComponent(
        componentContext = DefaultComponentContext(
            lifecycle = rememberLifecycleOwner().lifecycle
        )
    ))
}
