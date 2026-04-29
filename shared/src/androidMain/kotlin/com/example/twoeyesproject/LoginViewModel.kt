package com.example.twoeyesproject

import android.content.Context
import androidx.core.content.edit
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

const val ID_TOKEN_KEY = "idToken"
const val GIS_FILE_NAME = "gis_pref_file"

class LoginViewModel(context: Context) {
    val masterKeyAlias = MasterKey
        .Builder(context, MasterKey.DEFAULT_MASTER_KEY_ALIAS)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    val pref = EncryptedSharedPreferences.create(
        context,
        GIS_FILE_NAME,
        masterKeyAlias,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
    )

    fun saveIDToken(idToken: String) = pref.edit {
        putString(ID_TOKEN_KEY, idToken)
    }

    fun clearIDToken() = pref.edit {
        putString(ID_TOKEN_KEY, null)
    }

    fun getIDToken() = pref.getString(ID_TOKEN_KEY, null)
}