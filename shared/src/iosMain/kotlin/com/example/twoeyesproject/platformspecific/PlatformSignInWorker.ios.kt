package com.example.twoeyesproject.platformspecific

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.AuthenticationServices.ASAuthorizationAppleIDProvider
import platform.AuthenticationServices.ASAuthorizationController
import platform.AuthenticationServices.ASAuthorizationControllerPresentationContextProvidingProtocol
import platform.AuthenticationServices.ASAuthorizationScopeEmail
import platform.AuthenticationServices.ASAuthorizationScopeFullName
import platform.UIKit.UIApplication
import platform.UIKit.UIWindow
import platform.darwin.NSObject
import swiftPMImport.TwoEyesProject.shared.GIDSignIn
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

@OptIn(ExperimentalForeignApi::class)
actual class PlatformSignInWorker actual constructor(val uiContext: PlatformUIContext?) {
    @Throws(Exception::class)
    actual suspend fun signInWithGoogle(credential: String): SecureUserData.GoogleUserData =
        suspendCancellableCoroutine { continuation ->
            if (isTest) {
                // 빈 credential → 실패, 비어있지 않으면 → 성공 (Android와 동일한 동작)
                if (credential.isEmpty())
                    continuation.resumeWithException(IllegalStateException("Test: empty credential"))
                else
                    continuation.resume(SecureUserData.GoogleUserData("", "", "", "", "", ""))
                return@suspendCancellableCoroutine
            }

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
                                val googleUserData = SecureUserData.GoogleUserData(
                                    photoUrl = user.profile?.imageURLWithDimension(180u)?.absoluteString,
                                    name = user.profile?.name ?: "",
                                    givenName = user.profile?.givenName,
                                    familyName = user.profile?.familyName,
                                    email = user.profile?.email ?: "",
                                    idToken = user.idToken?.tokenString,
                                )

                                continuation.resume(googleUserData)
                            }
                        }
                    }
            } else {
                continuation.resumeWithException(IllegalStateException("UIViewController Not Found"))
            }
        }

    actual fun signInWithApple(delegate: PlatformASAuthorizationControllerDelegate) {
        if (isTest) {
            testSignInWithApple(delegate)
            return
        }

        val request = ASAuthorizationAppleIDProvider().createRequest().apply {
            requestedScopes = listOf(ASAuthorizationScopeEmail, ASAuthorizationScopeFullName)
        }
        val controller = ASAuthorizationController(listOf(request))
        controller.delegate = delegate

        // UIViewController 는 ASAuthorizationControllerPresentationContextProviding 을 직접 구현하지 않으므로
        // 익명 NSObject 구현체를 통해 window 를 제공
        val window: UIWindow = uiContext?.view?.window
            ?: UIApplication.sharedApplication.windows.firstOrNull() as? UIWindow
            ?: UIWindow()

        val presentationProvider = object : NSObject(), ASAuthorizationControllerPresentationContextProvidingProtocol {
            override fun presentationAnchorForAuthorizationController(
                controller: ASAuthorizationController
            ): UIWindow = window
        }

        controller.presentationContextProvider = presentationProvider
        controller.performRequests()
    }

    private fun testSignInWithApple(delegate: PlatformASAuthorizationControllerDelegate) =
        delegate.authorizationHandler?.let {
            it(SecureUserData.AppleUserData(
            "", "", "", "", "", "", ""))
        }

    actual var isTest: Boolean = false
}
