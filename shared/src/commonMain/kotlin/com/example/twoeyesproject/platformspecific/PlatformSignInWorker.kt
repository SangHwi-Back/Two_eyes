package com.example.twoeyesproject.platformspecific

expect class PlatformSignInWorker(uiContext: PlatformUIContext?) {
    suspend fun signInWithGoogle(credential: String): SecureUserData.GoogleUserData
}
