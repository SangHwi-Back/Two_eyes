package com.example.twoeyesproject

import kotlinx.coroutines.flow.Flow

interface Platform {
    val name: String
}

expect val isDebugBuild: Boolean

expect fun getPlatform(): Platform