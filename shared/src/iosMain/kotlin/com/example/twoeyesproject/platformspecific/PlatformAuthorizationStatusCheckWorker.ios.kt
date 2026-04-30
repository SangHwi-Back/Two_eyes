package com.example.twoeyesproject.platformspecific

import kotlinx.coroutines.suspendCancellableCoroutine
import platform.AuthenticationServices.ASAuthorizationAppleIDProvider
import platform.AuthenticationServices.ASAuthorizationAppleIDProviderCredentialState
import platform.darwin.NSObject
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

actual class PlatformAuthorizationStatusCheckWorker: NSObject() {
    actual suspend fun appleCheckState(userCredential: String): LoginStatusCheckResult = suspendCancellableCoroutine { continuation ->
        val provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialStateForUserID(userCredential) { state, error -> when {
            error != null
                -> continuation.resumeWithException(IllegalStateException(error.toString()))
            state == ASAuthorizationAppleIDProviderCredentialState.ASAuthorizationAppleIDProviderCredentialAuthorized
                -> continuation.resume(LoginStatusCheckResult.Authorized())
            else
                -> continuation.resume(LoginStatusCheckResult.NeedToSignIn(ProviderIdentifier.APPLE))
        } }
    }

    actual suspend fun googleCheckState(userCredential: String): LoginStatusCheckResult {
        return LoginStatusCheckResult.NotImplementedYet(ProviderIdentifier.APPLE)
    }
}

