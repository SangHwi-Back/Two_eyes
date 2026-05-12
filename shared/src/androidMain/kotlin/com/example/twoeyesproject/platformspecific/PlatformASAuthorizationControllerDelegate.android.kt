package com.example.twoeyesproject.platformspecific

// It is just for iOS. Android not using it.
actual class PlatformASAuthorizationControllerDelegate {
    actual var authorizationHandler: ((user: SecureUserData.AppleUserData?) -> Unit)? = null
    actual fun authorizationControllerWithAppleUser(user: SecureUserData.AppleUserData?) {}
}