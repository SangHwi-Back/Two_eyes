package com.example.twoeyesproject.platformspecific

expect class PlatformAuthorizationStatusCheckWorker() {
    suspend fun appleCheckState(userCredential: String): LoginStatusCheckResult
    suspend fun googleCheckState(userCredential: String): LoginStatusCheckResult
}

enum class ProviderIdentifier {
    APPLE, GOOGLE
}

sealed class LoginStatusCheckResult {
    class Authorized: LoginStatusCheckResult()
    data class NeedToSignIn(val identifier: ProviderIdentifier): LoginStatusCheckResult()
    class NotImplementedYet(val identifier: ProviderIdentifier): LoginStatusCheckResult()
}