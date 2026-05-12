package com.example.twoeyesproject.platformspecific

expect open class PlatformASAuthorizationControllerDelegate() {
    var authorizationHandler: ((user: SecureUserData.AppleUserData?) -> Unit)?
    fun authorizationControllerWithAppleUser(user: SecureUserData.AppleUserData?)
}