package com.example.twoeyesproject.platformspecific

import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import org.koin.core.component.KoinComponent
import org.koin.core.component.get
import java.security.SecureRandom
import java.util.Base64

@RequiresApi(Build.VERSION_CODES.O)
actual class PlatformSignInWorker: KoinComponent {
    val context: Context = get()
    actual suspend fun signIn(credential: String): SecureUserData {
        val signInWithGoogleOption: GetSignInWithGoogleOption = GetSignInWithGoogleOption
            .Builder(serverClientId = credential)
            .setNonce(generateSecureRandomNonce())
            .build()

        val request: GetCredentialRequest = GetCredentialRequest.Builder()
            .addCredentialOption(signInWithGoogleOption)
            .build()

        val credentialManager = CredentialManager.create(context)
        // The getCredential is called to request a credential from Credential Manager.
        val credential = credentialManager.getCredential(request = request, context = context).credential

        if (credential is GoogleIdTokenCredential) {
            return SecureUserData.GoogleUserData(
                url = parseUri(credential.profilePictureUri?.toString() ?: ""),
                name = credential.displayName ?: "",
                givenName = credential.givenName ?: "",
                familyName = credential.familyName ?: "",
                email = credential.email ?: "")
        } else {
            throw IllegalStateException("Unexpected credential type: ${credential::class}")
        }
    }

    fun generateSecureRandomNonce(byteLength: Int = 32): String {
        val randomBytes = ByteArray(byteLength)
        SecureRandom.getInstanceStrong().nextBytes(randomBytes)
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes)
    }
}