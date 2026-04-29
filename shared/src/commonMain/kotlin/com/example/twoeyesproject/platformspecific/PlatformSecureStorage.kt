package com.example.twoeyesproject.platformspecific

expect class PlatformSecureStorage {
    fun putString(key: String, value: String)
    fun getString(key: String): String?
    fun remove(key: String)
}