package com.example.twoeyesproject

import android.os.Build
import androidx.annotation.RequiresApi
import com.example.twoeyesproject.platformspecific.LoginStatusCheckResult
import com.example.twoeyesproject.platformspecific.PlatformAuthorizationStatusCheckWorker
import com.example.twoeyesproject.platformspecific.PlatformSecureStorage
import com.example.twoeyesproject.platformspecific.PlatformSignInWorker
import com.example.twoeyesproject.platformspecific.PlatformUIContext
import com.example.twoeyesproject.platformspecific.ProviderIdentifier
import com.example.twoeyesproject.platformspecific.SecureUserData
import com.example.twoeyesproject.platformspecific.getObject
import com.example.twoeyesproject.platformspecific.putObject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

const val ID_TOKEN_KEY = "idToken"
const val APPLE_SECURE_USER_DATA_KEY = "AppleUserData"
const val GOOGLE_SECURE_USER_DATA_KEY = "GoogleUserData"

@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
class LoginViewModel(
    uiContext: PlatformUIContext?
) {
    val storage = PlatformSecureStorage()
    val checkWorker = PlatformAuthorizationStatusCheckWorker()
    val signInWorker = PlatformSignInWorker(uiContext)

    private val _errorStatus = MutableStateFlow<LoginViewErrorStatus?>(null)
    val errorStatus = _errorStatus.asStateFlow()
    private val _userData = MutableStateFlow<SecureUserData?>(null)
    val userData = _userData.asStateFlow()

    // SAVE Data
    fun saveIDToken(idToken: String) =
        storage.putString(ID_TOKEN_KEY, idToken)
    fun saveUserData(userData: SecureUserData) {
        when (userData) {
            is SecureUserData.AppleUserData -> storage.putObject(APPLE_SECURE_USER_DATA_KEY, userData)
            is SecureUserData.GoogleUserData -> storage.putObject(GOOGLE_SECURE_USER_DATA_KEY, userData)
        }
    }

    // REMOVE Data
    fun clearIDToken() =
        storage.remove(ID_TOKEN_KEY)
    inline fun <reified T: SecureUserData> clearUserData() = when (T::class) {
        SecureUserData.AppleUserData::class ->
            storage.remove(APPLE_SECURE_USER_DATA_KEY)
        SecureUserData.GoogleUserData::class ->
            storage.remove(GOOGLE_SECURE_USER_DATA_KEY)
        else -> {}
    }

    // FETCH Data
    fun getIDToken() =
        storage.getString(ID_TOKEN_KEY)
    inline fun <reified T: SecureUserData> getUserData(): SecureUserData? {
        return when (T::class) {
            SecureUserData.AppleUserData::class ->
                storage.getObject<SecureUserData.AppleUserData>(APPLE_SECURE_USER_DATA_KEY)
            SecureUserData.GoogleUserData::class ->
                storage.getObject<SecureUserData.GoogleUserData>(GOOGLE_SECURE_USER_DATA_KEY)
            else -> null
        }
    }

    suspend fun appleCheckStatus(): LoginStatusCheckResult {
        val appleUserData = this.userData.value as? SecureUserData.AppleUserData
            ?: return LoginStatusCheckResult.NeedToSignIn(ProviderIdentifier.APPLE)

        val result = checkWorker.appleCheckState(appleUserData.user)
        return result
    }

    suspend fun googleCheckState(): LoginStatusCheckResult {
        val googleUserData = this.userData.value as? SecureUserData.GoogleUserData
            ?: return LoginStatusCheckResult.NeedToSignIn(ProviderIdentifier.GOOGLE)

        val result = checkWorker.googleCheckState(googleUserData.email)
        return result
    }
}

data class LoginViewErrorStatus(
    val providerIdentifier: ProviderIdentifier,
    val error: Exception?
) {
    val description: String = "[$providerIdentifier] ${error?.toString() ?: ""}"
}
