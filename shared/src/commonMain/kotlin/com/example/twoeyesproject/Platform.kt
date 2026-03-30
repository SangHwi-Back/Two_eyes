package com.example.twoeyesproject

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform