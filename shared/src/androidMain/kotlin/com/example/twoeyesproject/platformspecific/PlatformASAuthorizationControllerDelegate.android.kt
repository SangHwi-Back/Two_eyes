package com.example.twoeyesproject.platformspecific

// It is just for iOS. Android not using it.
actual open class PlatformASAuthorizationControllerDelegate {
    actual var authorizationHandler: ((user: SecureUserData.AppleUserData?) -> Unit)? = null
    actual fun authorizationControllerWithAppleUser(user: SecureUserData.AppleUserData?) {}
}