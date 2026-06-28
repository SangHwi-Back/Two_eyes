package com.example.twoeyesproject

import kotlinx.coroutines.flow.Flow

interface Platform {
    val name: String
}

expect val isDebugBuild: Boolean
expect class CommonFlow<T>(flow: Flow<T>)

fun <T> Flow<T>.toCommonFlow() = CommonFlow(this)

expect fun getPlatform(): Platform