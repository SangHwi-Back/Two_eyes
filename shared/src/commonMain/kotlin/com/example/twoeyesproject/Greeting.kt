package com.example.twoeyesproject

object AppConstants {
    const val APPLE_USER_DATA_KEY  = "AppleUserData"
    const val GOOGLE_USER_DATA_KEY = "GoogleUserData"

    const val ACCESS_TOKEN_KEY = "AccessToken"
    const val REFRESH_TOKEN_KEY = "RefreshToken"
    const val JWT_TOKEN_EXPIRES_TIME_KEY = "TokenExpiresIn"
}

class Greeting {
    private val platform = getPlatform()

    fun greet(): String {
        return "Hello, ${platform.name}!"
    }
}