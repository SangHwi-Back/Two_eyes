package com.example.twoeyesproject

import com.example.twoeyesproject.platformspecific.AppleUserData
import com.example.twoeyesproject.platformspecific.GoogleUserData
import com.example.twoeyesproject.platformspecific.PlatformSecureStorage
import com.example.twoeyesproject.platformspecific.getObject
import com.example.twoeyesproject.platformspecific.putObject

const val ID_TOKEN_KEY = "idToken"
const val APPLE_SECURE_USER_DATA_KEY = "AppleUserData"
const val GOOGLE_SECURE_USER_DATA_KEY = "GoogleUserData"

class LoginViewModel {
    private val storage = PlatformSecureStorage()

    // SAVE Data
    fun saveIDToken(idToken: String) =
        storage.putString(ID_TOKEN_KEY, idToken)
    fun saveAppleUserData(appleUserData: AppleUserData) =
        storage.putObject(APPLE_SECURE_USER_DATA_KEY, appleUserData)
    fun saveGoogleUserData(googleUserData: GoogleUserData) =
        storage.putObject(GOOGLE_SECURE_USER_DATA_KEY, googleUserData)

    // REMOVE Data
    fun clearIDToken() =
        storage.remove(ID_TOKEN_KEY)
    fun clearAppleUserData() =
        storage.remove(APPLE_SECURE_USER_DATA_KEY)
    fun clearGoogleUserData() =
        storage.remove(GOOGLE_SECURE_USER_DATA_KEY)

    // FETCH Data
    fun getIDToken() =
        storage.getString(ID_TOKEN_KEY)
    fun getAppleUserData() =
        storage.getObject<AppleUserData>(APPLE_SECURE_USER_DATA_KEY)
    fun getGoogleUserData() =
        storage.getObject<GoogleUserData>(GOOGLE_SECURE_USER_DATA_KEY)
}