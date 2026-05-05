package com.example.twoeyesproject.platformspecific

expect class PlatformSignInWorker(uiContext: PlatformUIContext?) {
    fun signInWithApple(delegate: PlatformASAuthorizationControllerDelegate)
    @Throws(Exception::class)
    suspend fun signInWithGoogle(credential: String): SecureUserData.GoogleUserData
}
