package com.example.twoeyesproject.platformspecific

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

expect class PlatformSecureStorage {
    fun putString(key: String, value: String)
    fun getString(key: String): String?
    fun remove(key: String)
}

inline fun <reified T>PlatformSecureStorage.putObject(key: String, value: T) {
    val json = Json.encodeToString(value)
    putString(key, json)
}
inline fun <reified T>PlatformSecureStorage.getObject(key: String): T? {
    val json = getString(key) ?: return null
    return runCatching { Json.decodeFromString<T>(json) }.getOrNull()
}

@Serializable
data class AppleUserData(
    val user: String,
    val password: String?,
    val givenName: String?,
    val familyName: String?,
    val email: String?,
    val identityToken: String?,
    val authorizationCode: String?,
) {
    val name: String =
        (familyName ?: "") + (if (givenName.isNullOrEmpty()) " " else "") + (givenName ?: "")
}

@Serializable
data class GoogleUserData(
    val url: PlatformUri?,
    val name: String,
    val givenName: String?,
    val familyName: String?,
    val email: String,
)