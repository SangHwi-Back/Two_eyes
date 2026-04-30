package com.example.twoeyesproject.platformspecific

expect class PlatformSignInWorker {
    suspend fun signIn(credential: String): SecureUserData
}
