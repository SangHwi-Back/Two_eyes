package com.example.twoeyesproject

object AppConstants {
    const val APPLE_USER_DATA_KEY  = "AppleUserData"
    const val GOOGLE_USER_DATA_KEY = "GoogleUserData"

    const val ACCESS_TOKEN_KEY = "AccessToken"
    const val REFRESH_TOKEN_KEY = "RefreshToken"

    const val THUMBNAIL_SIZE_WIDTH = 120
    const val THUMBNAIL_SIZE_HEIGHT = 190
    const val THUMBNAIL_ASPECT_RATIO = 1.58f

    const val ICON_SIZE_WIDTH = 40
    const val ICON_SIZE_HEIGHT = 40

    const val CARD_CORNER_RADIUS = 8
}

class Greeting {
    private val platform = getPlatform()

    fun greet(): String {
        return "Hello, ${platform.name}!"
    }
}