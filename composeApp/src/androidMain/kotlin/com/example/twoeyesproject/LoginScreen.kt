package com.example.twoeyesproject

import android.annotation.SuppressLint
import android.content.ContentValues.TAG
import android.content.Context
import android.credentials.GetCredentialException
import android.os.Build
import android.util.Log
import androidx.activity.compose.LocalActivity
import androidx.annotation.RequiresApi
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialCustomException
import androidx.credentials.exceptions.NoCredentialException
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.android.libraries.identity.googleid.GoogleIdTokenParsingException
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.security.SecureRandom
import java.util.Base64

@SuppressLint("NewApi")
@Preview(showBackground = true)
@Composable
fun LoginScreen() {
    val context = LocalContext.current
    val activity = LocalActivity.current
    val viewmodel: LoginViewModel by remember {
        mutableStateOf(LoginViewModel(activity))
    }
    val scope = rememberCoroutineScope()
    var errorStatus by remember { mutableStateOf(false) }

    Column(Modifier.fillMaxSize()) {
        Spacer(Modifier.fillMaxHeight())

        if (errorStatus) {
            Button({
                errorStatus = false
            }) {
                Text("Remove Error")
            }
        }

        ButtonUI(BuildConfig.GIS_CLIENT_ID) { request, context ->
            scope.launch {
                signIn(request, context) { exception, idToken ->
                    if (exception is NoCredentialException) {
                        viewmodel.clearIDToken()
                    }
                    else if (exception != null || idToken == null) {
                        errorStatus = true
                    }
                    else {
                        viewmodel.saveIDToken(idToken)
                    }
                }
            }
        }

        if (viewmodel.getIDToken().isNullOrEmpty()) {
            BottomSheet(BuildConfig.GIS_CLIENT_ID) { exception, idToken ->
                if (idToken != null) {
                    viewmodel.saveIDToken(idToken)
                }
                else if (exception is NoCredentialException) {
                    val googleIdOptionFalse: GetGoogleIdOption = GetGoogleIdOption.Builder()
                        .setFilterByAuthorizedAccounts(false)
                        .setServerClientId(BuildConfig.GIS_CLIENT_ID)
                        .setNonce(generateSecureRandomNonce())
                        .build()

                    val requestFalse: GetCredentialRequest = GetCredentialRequest.Builder()
                        .addCredentialOption(googleIdOptionFalse)
                        .build()

                    //We will build out this function in a moment
                    scope.launch {
                        signIn(requestFalse, context) { exception, idToken ->
                            if (exception == null || idToken == null) {
                                errorStatus = true
                            }
                            else {
                                viewmodel.saveIDToken(idToken)
                            }
                        }
                    }
                }
            }
        }
    }
}

@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
@Composable
fun ButtonUI(webClientId: String, completionHandler: (GetCredentialRequest, Context) -> Unit) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    val onClick: () -> Unit = {
        val signInWithGoogleOption: GetSignInWithGoogleOption = GetSignInWithGoogleOption
            .Builder(serverClientId = webClientId)
            .setNonce(generateSecureRandomNonce())
            .build()

        val request: GetCredentialRequest = GetCredentialRequest.Builder()
            .addCredentialOption(signInWithGoogleOption)
            .build()

        coroutineScope.launch {
            completionHandler(request, context)
        }
    }
    Image(
        painter = painterResource(id = R.drawable.siwg_button),
        contentDescription = "",
        modifier = Modifier
            .fillMaxWidth()
            .height(60.dp)
            .clickable(enabled = true, onClick = onClick)
    )
}

// This code will not work on Android versions < UPSIDE_DOWN_CAKE when GetCredentialException is thrown.
@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
suspend fun signIn(request: GetCredentialRequest, context: Context, completionHandler: (Exception?, String?) -> Unit) {
    var e: Exception?
    // Using delay() here helps prevent NoCredentialException when the BottomSheet Flow is triggered on the initial running of our app
    delay(250)
    try {
        val credentialManager = CredentialManager.create(context)
        // The getCredential is called to request a credential from Credential Manager.
        val credential = credentialManager.getCredential(request = request, context = context).credential

        if (credential is GoogleIdTokenCredential) {
            completionHandler(null, credential.idToken)
        } else {
            completionHandler(IllegalStateException("Unexpected credential type: ${credential::class}"), null)
        }

        Log.i(TAG, "Sign in Successful!")
        return

    } catch (exception: GetCredentialException) {
        Log.e(TAG, "Sign in failed!: Failure getting credentials", exception)
        e = exception

    } catch (exception: GoogleIdTokenParsingException) {
        Log.e(TAG, "Sign in failed!: Issue with parsing received GoogleIdToken", exception)
        e = exception

    } catch (exception: NoCredentialException) {
        Log.e(TAG, "Sign in failed!: No credentials found", exception)
        e = exception

    } catch (exception: GetCredentialCustomException) {
        Log.e(TAG, "Sign in failed!: Issue with custom credential request", exception)
        e = exception

    } catch (exception: GetCredentialCancellationException) {
        Log.e(TAG, "Sign in failed!: Sign-in was cancelled", exception)
        e = exception
    }

    completionHandler(e, null)
}

//This line is not needed for the project to build, but you will see errors if it is not present.
//This code will not work on Android versions < UpsideDownCake
@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
@Composable
fun BottomSheet(webClientId: String, completionHandler: (Exception?, String?) -> Unit) {
    val context = LocalContext.current

    // LaunchedEffect is used to run a suspend function when the composable is first launched.
    LaunchedEffect(Unit) {
        // Create a Google ID option with filtering by authorized accounts enabled.
        val googleIdOption: GetGoogleIdOption = GetGoogleIdOption.Builder()
            .setFilterByAuthorizedAccounts(true)
            .setServerClientId(webClientId)
            .setNonce(generateSecureRandomNonce())
            .build()

        // Create a credential request with the Google ID option.
        val request: GetCredentialRequest = GetCredentialRequest.Builder()
            .addCredentialOption(googleIdOption)
            .build()

        // Attempt to sign in with the created request using an authorized account
        signIn(request, context, completionHandler)
    }
}

//This function is used to generate a secure nonce to pass in with our request
@RequiresApi(Build.VERSION_CODES.O)
fun generateSecureRandomNonce(byteLength: Int = 32): String {
    val randomBytes = ByteArray(byteLength)
    SecureRandom.getInstanceStrong().nextBytes(randomBytes)
    return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes)
}