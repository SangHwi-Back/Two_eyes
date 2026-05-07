package com.example.twoeyesproject.platformspecific

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.AuthenticationServices.ASAuthorizationAppleIDProvider
import platform.AuthenticationServices.ASAuthorizationAppleIDProviderCredentialState
import platform.darwin.NSObject
import swiftPMImport.TwoEyesProject.shared.GIDSignIn
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
        GIDSignIn.sharedInstance.restorePreviousSignInWithCompletion { googleUser, error ->
            if (error != null) {
                continuation.resumeWithException(RuntimeException(error.localizedDescription))
                return@restorePreviousSignInWithCompletion
            }
            val profile = googleUser?.profile

            if (profile != null) {
                continuation.resume(LoginStatusCheckResult.Authorized(SecureUserData.GoogleUserData(
                    photoUrl = profile.imageURLWithDimension(180u)?.absoluteString,
                    name = profile.name,
                    givenName = profile.givenName,
                    familyName = profile.familyName,
                    email = profile.email,
                    idToken = null
                )))
            } else {
                continuation.resume(LoginStatusCheckResult.NeedToSignIn(ProviderIdentifier.GOOGLE))
            }
        }
    }
}

