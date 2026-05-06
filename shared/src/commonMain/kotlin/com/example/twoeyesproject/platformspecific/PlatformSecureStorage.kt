package com.example.twoeyesproject.platformspecific

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

expect class PlatformSecureStorage() {
    fun putString(key: String, value: String)
    fun getString(key: String): String?
    fun remove(key: String)
}

// ── Swift/ObjC 에서 호출 가능한 타입 명시 함수 ───────────────────────────────
// (reified 없이 구체 타입을 직접 사용 → KMP 바이너리 경계를 안전하게 넘김)
const val APPLE_USER_DATA_KEY  = "AppleUserData"
const val GOOGLE_USER_DATA_KEY = "GoogleUserData"

fun PlatformSecureStorage.putAppleUserData(value: SecureUserData.AppleUserData) =
    putString(APPLE_USER_DATA_KEY, Json.encodeToString(value))

fun PlatformSecureStorage.getAppleUserData(): SecureUserData.AppleUserData? {
    val json = getString(APPLE_USER_DATA_KEY) ?: return null
    return runCatching { Json.decodeFromString<SecureUserData.AppleUserData>(json) }.getOrNull()
}

fun PlatformSecureStorage.putGoogleUserData(value: SecureUserData.GoogleUserData) =
    putString(GOOGLE_USER_DATA_KEY, Json.encodeToString(value))

fun PlatformSecureStorage.getGoogleUserData(): SecureUserData.GoogleUserData? {
    val json = getString(GOOGLE_USER_DATA_KEY) ?: return null
    return runCatching { Json.decodeFromString<SecureUserData.GoogleUserData>(json) }.getOrNull()
}

@Serializable
sealed class SecureUserData {
    @Serializable
    data class AppleUserData(
        val user: String,
        val password: String?,
        val givenName: String?,
        val familyName: String?,
        val email: String?,
        val identityToken: String?,
        val authorizationCode: String?,
    ): SecureUserData() {
        val name: String
            get() = (familyName ?: "") + (if (!givenName.isNullOrEmpty()) " " else "") + (givenName ?: "")
    }

    @Serializable
    data class GoogleUserData(
        val photoUrl: String?,
        val name: String,
        val givenName: String?,
        val familyName: String?,
        val email: String,
        val idToken: String?,
    ): SecureUserData()
}