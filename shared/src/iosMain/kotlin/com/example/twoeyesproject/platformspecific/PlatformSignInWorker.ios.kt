package com.example.twoeyesproject.platformspecific

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.AuthenticationServices.ASAuthorizationAppleIDProvider
import platform.AuthenticationServices.ASAuthorizationController
import platform.AuthenticationServices.ASAuthorizationControllerPresentationContextProvidingProtocol
import platform.AuthenticationServices.ASAuthorizationScopeEmail
import platform.AuthenticationServices.ASAuthorizationScopeFullName
import swiftPMImport.TwoEyesProject.shared.GIDSignIn
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

@OptIn(ExperimentalForeignApi::class)
actual class PlatformSignInWorker actual constructor(val uiContext: PlatformUIContext?) {
    actual suspend fun signInWithGoogle(credential: String): SecureUserData.GoogleUserData =
        suspendCancellableCoroutine { continuation ->
            if (uiContext != null) {
                GIDSignIn
                    .sharedInstance
                    .signInWithPresentingViewController(uiContext) { result, error ->
                        when {
                            error != null ->
                                continuation.resumeWithException(IllegalStateException(error.toString()))
                            result?.user == null ->
                                continuation.resumeWithException(IllegalStateException("Google Sign-in failed"))
                            else -> {
                                val user = result.user
                                val uriString = user.profile?.imageURLWithDimension(0u)?.toString() ?: ""
                                continuation.resume(SecureUserData.GoogleUserData(
                                    name = user.profile?.name ?: "",
                                    email = user.profile?.email ?: "",
                                    givenName = user.profile?.givenName,
                                    familyName = user.profile?.familyName,
                                    url = parseUri(uriString)
                                ))
                            }
                        }
                    }
            } else {
                continuation.resumeWithException(IllegalStateException("UIViewController Not Found"))
            }
        }

    suspend fun signInWithApple(): SecureUserData.AppleUserData = suspendCancellableCoroutine {
        val provider = uiContext as? ASAuthorizationControllerPresentationContextProvidingProtocol
            ?: throw IllegalArgumentException("Please implement ASAuthorizationControllerPresentationContextProviding!!")
        val request = ASAuthorizationAppleIDProvider().createRequest().apply {
            requestedScopes = listOf(ASAuthorizationScopeEmail, ASAuthorizationScopeFullName)
        }
        val controller = ASAuthorizationController(listOf(request))
        controller.presentationContextProvider = provider
        controller.performRequests()
    }
}
