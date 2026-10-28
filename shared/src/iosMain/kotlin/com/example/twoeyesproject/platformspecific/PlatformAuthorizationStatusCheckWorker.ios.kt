package com.example.twoeyesproject.platformspecific

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.AuthenticationServices.ASAuthorizationAppleIDProvider
import platform.AuthenticationServices.ASAuthorizationAppleIDProviderCredentialState
import platform.darwin.NSObject
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

@OptIn(ExperimentalForeignApi::class)
actual class PlatformAuthorizationStatusCheckWorker: NSObject() {
    actual suspend fun appleCheckState(userCredential: String): LoginStatusCheckResult = suspendCancellableCoroutine { continuation ->
        val provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialStateForUserID(userCredential) { state, error -> when {
            error != null
                -> continuation.resumeWithException(RuntimeException(error.localizedDescription))
            state == ASAuthorizationAppleIDProviderCredentialState.ASAuthorizationAppleIDProviderCredentialAuthorized
                -> continuation.resume(LoginStatusCheckResult.Authorized(null))
            else
                -> continuation.resume(LoginStatusCheckResult.NeedToSignIn(ProviderIdentifier.APPLE))
        } }
    }

    actual suspend fun googleCheckState(userCredential: String): LoginStatusCheckResult = suspendCancellableCoroutine { continuation ->
        val bridge = GoogleSignInBridgeRegistry.bridge
        if (bridge == null) {
            continuation.resumeWithException(IllegalStateException("GoogleSignInBridge is not registered"))
            return@suspendCancellableCoroutine
        }
        bridge.restorePreviousSignIn(object : GoogleSignInCallback {
            override fun onResult(user: SecureUserData.GoogleUserData?, errorMessage: String?) {
                when {
                    errorMessage != null ->
                        continuation.resumeWithException(RuntimeException(errorMessage))
                    user != null ->
                        continuation.resume(LoginStatusCheckResult.Authorized(user))
                    else ->
                        continuation.resume(LoginStatusCheckResult.NeedToSignIn(ProviderIdentifier.GOOGLE))
                }
            }
        })
    }
}
