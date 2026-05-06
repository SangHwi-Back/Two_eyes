package com.example.twoeyesproject

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.platformspecific.APPLE_USER_DATA_KEY
import com.example.twoeyesproject.platformspecific.GOOGLE_USER_DATA_KEY
import com.example.twoeyesproject.platformspecific.LoginStatusCheckResult
import com.example.twoeyesproject.platformspecific.PlatformASAuthorizationControllerDelegate
import com.example.twoeyesproject.platformspecific.PlatformAuthorizationStatusCheckWorker
import com.example.twoeyesproject.platformspecific.PlatformSecureStorage
import com.example.twoeyesproject.platformspecific.PlatformSignInWorker
import com.example.twoeyesproject.platformspecific.PlatformUIContext
import com.example.twoeyesproject.platformspecific.ProviderIdentifier
import com.example.twoeyesproject.platformspecific.SecureUserData
import com.example.twoeyesproject.platformspecific.getAppleUserData
import com.example.twoeyesproject.platformspecific.getGoogleUserData
import com.example.twoeyesproject.platformspecific.putAppleUserData
import com.example.twoeyesproject.platformspecific.putGoogleUserData
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class LoginViewModel(
    val context: PlatformUIContext?
) : ViewModel() {
    val storage    = PlatformSecureStorage()
    val checkWorker = PlatformAuthorizationStatusCheckWorker()
    val signInWorker = PlatformSignInWorker(context)
    val delegate   = PlatformASAuthorizationControllerDelegate()

    private val _errorStatus = MutableStateFlow<LoginViewErrorStatus?>(null)
    val errorStatus = _errorStatus.asStateFlow()

    private val _userData = MutableStateFlow<SecureUserData?>(null)
    val userData = _userData.asStateFlow()

    // ── SAVE ───────────────────────────────────────────────────────────────────
    fun saveUserData(userData: SecureUserData) = when (userData) {
        is SecureUserData.AppleUserData  -> storage.putAppleUserData(userData)
        is SecureUserData.GoogleUserData -> storage.putGoogleUserData(userData)
    }

    // ── REMOVE ─────────────────────────────────────────────────────────────────
    fun clearAppleUserData()  = storage.remove(APPLE_USER_DATA_KEY)
    fun clearGoogleUserData() = storage.remove(GOOGLE_USER_DATA_KEY)

    // ── FETCH ──────────────────────────────────────────────────────────────────
    fun getAppleUserData()  = storage.getAppleUserData()
    fun getGoogleUserData() = storage.getGoogleUserData()

    // ── Apple Sign In ──────────────────────────────────────────────────────────
    suspend fun appleCheckStatus(): LoginStatusCheckResult {
        if (getPlatform().name.startsWith("Android"))
            return LoginStatusCheckResult.NotImplementedYet(ProviderIdentifier.APPLE)

        // _userData 가 null 이면 저장소에서 로드 (앱 재시작 후 flow 가 초기화된 경우)
        val appleUserData = (_userData.value as? SecureUserData.AppleUserData)
            ?: storage.getAppleUserData()
            ?: return LoginStatusCheckResult.NeedToSignIn(ProviderIdentifier.APPLE)

        val result = checkWorker.appleCheckState(appleUserData.user)

        // Apple 은 재로그인 없이 자격증명 상태만 확인 (userInfo 는 최초 로그인 시에만 반환됨)
        if (result is LoginStatusCheckResult.Authorized && result.userInfo != null) {
            val freshData = result.userInfo as? SecureUserData.AppleUserData ?: appleUserData
            storage.putAppleUserData(freshData)
            _userData.value = freshData
            return LoginStatusCheckResult.Authorized(freshData)
        }
        return result
    }

    fun signInWithApple() {
        delegate.authorizationHandler = { user ->
            if (user != null) {
                storage.putAppleUserData(user)
                _userData.value = user   // flow 갱신 → wrapper.userData → 뷰 자동 dismiss
            } else {
                _errorStatus.value = LoginViewErrorStatus(ProviderIdentifier.APPLE, null)
            }
        }
        signInWorker.signInWithApple(delegate)
    }

    fun signInWithGoogle(credential: String) {
        viewModelScope.launch {
            try {
                val result = signInWorker.signInWithGoogle(credential)
                storage.putGoogleUserData(result)
                _userData.value = result
            } catch (e: Exception) {
                _errorStatus.value = LoginViewErrorStatus(ProviderIdentifier.GOOGLE, e)
            }
        }
    }

    // ── Google Sign In ─────────────────────────────────────────────────────────
    @Throws(Exception::class)
    suspend fun googleCheckState(): LoginStatusCheckResult {
        val googleUserData = (_userData.value as? SecureUserData.GoogleUserData)
            ?: storage.getGoogleUserData()
            ?: return LoginStatusCheckResult.NeedToSignIn(ProviderIdentifier.GOOGLE)

        return checkWorker.googleCheckState(googleUserData.email)
    }
}

data class LoginViewErrorStatus(
    val providerIdentifier: ProviderIdentifier,
    val error: Exception?,
) {
    val description: String = "[$providerIdentifier] ${error?.toString() ?: ""}"
}
