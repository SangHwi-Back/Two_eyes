package com.example.twoeyesproject.platformspecific

import android.content.Context
import androidx.core.content.edit
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import org.koin.core.component.KoinComponent
import org.koin.core.component.get

private const val PREFS_FILE_NAME = "two_eyes_secure_prefs"

actual class PlatformSecureStorage: KoinComponent {
    val context: Context = get()
    private val prefs by lazy {
        // lateinit var context 대신 androidApplicationContext 사용
        // (Application.onCreate 에서 initPlatformContext 를 반드시 먼저 호출해야 함)
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()

        EncryptedSharedPreferences.create(
            context,
            PREFS_FILE_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    actual fun putString(key: String, value: String) {
        prefs.edit { putString(key, value) }
    }

    actual fun getString(key: String): String? = prefs.getString(key, null)

    actual fun remove(key: String) {
        prefs.edit { remove(key) }
    }
}
