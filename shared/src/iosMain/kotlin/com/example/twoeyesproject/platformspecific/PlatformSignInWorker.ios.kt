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

            val bridge = GoogleSignInBridgeRegistry.bridge
            when {
                uiContext == null ->
                    continuation.resumeWithException(IllegalStateException("UIViewController Not Found"))
                bridge == null ->
                    continuation.resumeWithException(IllegalStateException("GoogleSignInBridge is not registered"))
                else -> bridge.signIn(uiContext, object : GoogleSignInCallback {
                    override fun onResult(user: SecureUserData.GoogleUserData?, errorMessage: String?) {
                        when {
                            errorMessage != null ->
                                continuation.resumeWithException(IllegalStateException(errorMessage))
                            user == null ->
                                continuation.resumeWithException(IllegalStateException("Google Sign-in failed"))
                            else -> continuation.resume(user)
                        }
                    }
                })
            }
        }

    @Throws(RuntimeException::class)
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
        val window: UIWindow? = uiContext?.view?.window
            ?: UIApplication.sharedApplication.windows.firstOrNull() as? UIWindow

        if (window != null) {
            val presentationProvider = object : NSObject(), ASAuthorizationControllerPresentationContextProvidingProtocol {
                override fun presentationAnchorForAuthorizationController(
                    controller: ASAuthorizationController
                ): UIWindow = window
            }

            controller.presentationContextProvider = presentationProvider
            controller.performRequests()
        } else {
            throw RuntimeException("Unable to find a window for ASAuthorizationController")
        }
    }

    private fun testSignInWithApple(delegate: PlatformASAuthorizationControllerDelegate) =
        delegate.authorizationHandler?.let {
            it(SecureUserData.AppleUserData(
            "", "", "", "", "", "", ""))
        }

    actual var isTest: Boolean = false
}
