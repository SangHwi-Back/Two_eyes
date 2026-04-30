package com.example.twoeyesproject.platformspecific

import android.content.ContentValues.TAG
import android.content.Context
import android.credentials.GetCredentialException
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.platform.LocalContext
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialCustomException
import androidx.credentials.exceptions.NoCredentialException
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.android.libraries.identity.googleid.GoogleIdTokenParsingException
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import org.koin.core.component.KoinComponent
import org.koin.core.component.get
import java.security.SecureRandom
import java.util.Base64

@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
actual class PlatformAuthorizationStatusCheckWorker: KoinComponent {
    val context: Context = get()
    actual suspend fun appleCheckState(userCredential: String): LoginStatusCheckResult {
        return LoginStatusCheckResult.NotImplementedYet(ProviderIdentifier.APPLE)
    }

    actual suspend fun googleCheckState(userCredential: String): LoginStatusCheckResult {


        val signInWithGoogleOption: GetSignInWithGoogleOption = GetSignInWithGoogleOption
            .Builder(serverClientId = userCredential)
            .setNonce(generateSecureRandomNonce())
            .build()

        val request: GetCredentialRequest = GetCredentialRequest.Builder()
            .addCredentialOption(signInWithGoogleOption)
            .build()

        val result = signIn(request, context)
        return result
    }
    //This function is used to generate a secure nonce to pass in with our request
    fun generateSecureRandomNonce(byteLength: Int = 32): String {
        val randomBytes = ByteArray(byteLength)
        SecureRandom.getInstanceStrong().nextBytes(randomBytes)
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes)
    }

    suspend fun signIn(request: GetCredentialRequest, context: Context): LoginStatusCheckResult {
        var e: Exception?
        // Using delay() here helps prevent NoCredentialException when the BottomSheet Flow is triggered on the initial running of our app
        delay(250)
        try {
            val credentialManager = CredentialManager.create(context)
            // The getCredential is called to request a credential from Credential Manager.
            val credential = credentialManager.getCredential(request = request, context = context).credential
            // TODO:
//            if (credential is GoogleIdTokenCredential) {
//                completionHandler(null, credential.idToken)
//            } else {
//                completionHandler(IllegalStateException("Unexpected credential type: ${credential::class}"), null)
//            }

            Log.i(TAG, "Sign in Successful!")
            return LoginStatusCheckResult.NeedToSignIn(ProviderIdentifier.GOOGLE)

        } catch (exception: GetCredentialException) {
            Log.e(TAG, "Sign in failed!: Failure getting credentials", exception)
            throw exception

        } catch (exception: GoogleIdTokenParsingException) {
            Log.e(TAG, "Sign in failed!: Issue with parsing received GoogleIdToken", exception)
            throw exception

        } catch (exception: NoCredentialException) {
            Log.e(TAG, "Sign in failed!: No credentials found", exception)
            throw exception

        } catch (exception: GetCredentialCustomException) {
            Log.e(TAG, "Sign in failed!: Issue with custom credential request", exception)
            throw exception

        } catch (exception: GetCredentialCancellationException) {
            Log.e(TAG, "Sign in failed!: Sign-in was cancelled", exception)
            throw exception
        }
    }
}