package com.example.twoeyesproject.platformspecific

import platform.AuthenticationServices.ASAuthorization
import platform.AuthenticationServices.ASAuthorizationAppleIDCredential
import platform.AuthenticationServices.ASAuthorizationController
import platform.AuthenticationServices.ASAuthorizationControllerDelegateProtocol
import platform.AuthenticationServices.ASPasswordCredential
import platform.Foundation.NSError
import platform.Foundation.NSString
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.create
import platform.darwin.NSObject

actual open class PlatformASAuthorizationControllerDelegate: NSObject(), ASAuthorizationControllerDelegateProtocol {
    actual var authorizationHandler: ((user: SecureUserData.AppleUserData?) -> Unit)? = null
    actual fun authorizationControllerWithAppleUser(user: SecureUserData.AppleUserData?) {
        authorizationHandler?.invoke(user)
    }

    override fun authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization: ASAuthorization
    ) {
        val credential = didCompleteWithAuthorization.credential

        if (credential is ASAuthorizationAppleIDCredential) {
            authorizationControllerWithAppleUser(SecureUserData.AppleUserData(
                user = credential.user,
                password = null,
                givenName = credential.fullName?.givenName,
                familyName = credential.fullName?.familyName,
                email = credential.email,
                identityToken = credential.identityToken?.let {
                    NSString.create(data = it, encoding = NSUTF8StringEncoding)?.toString()
                },
                authorizationCode = credential.authorizationCode?.let {
                    NSString.create(data = it, encoding = NSUTF8StringEncoding)?.toString()
                }
            ))
        }
        else if (credential is ASPasswordCredential) {
            authorizationControllerWithAppleUser(SecureUserData.AppleUserData(
                user = credential.user,
                password = credential.password,
                givenName = null,
                familyName = null,
                email = null,
                identityToken = null,
                authorizationCode = null
            ))
        }
        else {
            authorizationControllerWithAppleUser(null)
        }
    }

    override fun authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError: NSError
    ) {
        // 기본 에러 처리 (또는 빈 구현)
    }
}