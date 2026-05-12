package com.example.twoeyesproject.platformspecific

import android.os.Build
import androidx.annotation.RequiresApi
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import java.security.SecureRandom
import java.util.Base64

@RequiresApi(Build.VERSION_CODES.O)
actual class PlatformSignInWorker actual constructor(val uiContext: PlatformUIContext?) {
    @Throws(Exception::class)
    actual suspend fun signInWithGoogle(credential: String): SecureUserData.GoogleUserData {
        if (isTest)
            return testSignInWithGoogle(credential)
        if (uiContext == null) {
            throw IllegalStateException("Activity Not Found")
        }

        val signInWithGoogleOption: GetSignInWithGoogleOption = GetSignInWithGoogleOption
            .Builder(serverClientId = credential)
            .setNonce(generateSecureRandomNonce())
            .build()

        val request: GetCredentialRequest = GetCredentialRequest.Builder()
            .addCredentialOption(signInWithGoogleOption)
            .build()

        val credentialManager = CredentialManager.create(uiContext)
        // The getCredential is called to request a credential from Credential Manager.
        val credential = credentialManager.getCredential(request = request, context = uiContext).credential

        when (credential) {
            is GoogleIdTokenCredential ->
                return credential.toGoogleUserData()
            else ->
                throw IllegalStateException("Unexpected credential type: ${credential::class}")
        }
    }

    @Throws(Exception::class)
    private fun testSignInWithGoogle(credential: String): SecureUserData.GoogleUserData {
        if (credential.isEmpty())
            throw IllegalStateException("Unexpected credential type: ${credential::class}")
        else
            return SecureUserData.GoogleUserData(
                "", "", "", "", "", "")
    }

    fun generateSecureRandomNonce(byteLength: Int = 32): String {
        val randomBytes = ByteArray(byteLength)
        SecureRandom.getInstanceStrong().nextBytes(randomBytes)
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes)
    }

    actual fun signInWithApple(delegate: PlatformASAuthorizationControllerDelegate) {}

    private fun GoogleIdTokenCredential.toGoogleUserData() = SecureUserData.GoogleUserData(
        photoUrl = profilePictureUri?.toString(),
        name = displayName ?: "",
        givenName = givenName,
        familyName = familyName,
        email = id,
        idToken = idToken)

    actual var isTest: Boolean = false
}