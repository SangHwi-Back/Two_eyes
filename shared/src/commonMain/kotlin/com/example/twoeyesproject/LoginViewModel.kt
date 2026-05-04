package com.example.twoeyesproject

import androidx.lifecycle.ViewModel
import com.example.twoeyesproject.platformspecific.LoginStatusCheckResult
import com.example.twoeyesproject.platformspecific.PlatformASAuthorizationControllerDelegate
import com.example.twoeyesproject.platformspecific.PlatformSecureStorage
import com.example.twoeyesproject.platformspecific.PlatformUIContext
import com.example.twoeyesproject.platformspecific.PlatformAuthorizationStatusCheckWorker
import com.example.twoeyesproject.platformspecific.PlatformSignInWorker
import com.example.twoeyesproject.platformspecific.ProviderIdentifier
import com.example.twoeyesproject.platformspecific.SecureUserData
import com.example.twoeyesproject.platformspecific.getObject
import com.example.twoeyesproject.platformspecific.putObject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

const val ID_TOKEN_KEY = "idToken"
const val APPLE_SECURE_USER_DATA_KEY = "AppleUserData"
const val GOOGLE_SECURE_USER_DATA_KEY = "GoogleUserData"

class LoginViewModel(
    context: PlatformUIContext?
): ViewModel() {
    val storage = PlatformSecureStorage()
    val checkWorker = PlatformAuthorizationStatusCheckWorker()
    val signInWorker = PlatformSignInWorker(context)
    val delegate = PlatformASAuthorizationControllerDelegate()

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
        if (getPlatform().name.startsWith("Android"))
            return LoginStatusCheckResult.NotImplementedYet(ProviderIdentifier.APPLE)

        // _userData 가 null 이면 저장소에서 로드 (앱 재시작 후 flow 가 초기화된 경우)
        val appleUserData = (_userData.value as? SecureUserData.AppleUserData)
            ?: storage.getObject<SecureUserData.AppleUserData>(APPLE_SECURE_USER_DATA_KEY)
            ?: return LoginStatusCheckResult.NeedToSignIn(ProviderIdentifier.APPLE)

        val result = checkWorker.appleCheckState(appleUserData.user)

        // Apple 은 재로그인 없이 자격증명 상태만 확인 (userInfo 는 최초 로그인 시에만 반환됨)
        if (result is LoginStatusCheckResult.Authorized && result.userInfo != null) {
            val freshData = result.userInfo as? SecureUserData.AppleUserData ?: appleUserData
            storage.putObject(APPLE_SECURE_USER_DATA_KEY, freshData)
            _userData.value = freshData
            return LoginStatusCheckResult.Authorized(freshData)
        }

        return result
    }

    fun signInWithApple() {
        delegate.authorizationHandler = { user ->
            if (user != null) {
                storage.putObject(APPLE_SECURE_USER_DATA_KEY, user)
                _userData.value = user  // flow 갱신 → wrapper.userData 변경 → 뷰 자동 dismiss
            } else {
                _errorStatus.value = LoginViewErrorStatus(ProviderIdentifier.APPLE, null)
            }
        }
        signInWorker.signInWithApple(delegate)
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
