package com.example.twoeyesproject

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable

@Composable
fun LoginScreen() {
    Column() {
        Button({}) {
            Text("Google Sign in")
        }
        Button({}) {
            Text("Apple Sign in")
        }
    }
}