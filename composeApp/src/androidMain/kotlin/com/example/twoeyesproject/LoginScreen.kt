package com.example.twoeyesproject

import android.annotation.SuppressLint
import android.content.ContentValues.TAG
import android.content.Context
import android.os.Build
import android.util.Log
import androidx.activity.compose.LocalActivity
import androidx.annotation.RequiresApi
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
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
@Composable
fun LoginScreen() {
    val context = LocalContext.current
    val activity = LocalActivity.current

    // ViewModel은 remember로 직접 생성 (lifecycle-viewmodel-compose 미사용 시)
    val viewModel = remember { LoginViewModel(activity) }
    val scope = rememberCoroutineScope()

    var isLoading by remember { mutableStateOf(false) }
    var isSignedIn by remember { mutableStateOf(false) }
    val snackbarHostState = remember { SnackbarHostState() }

    // 앱 시작 시 이미 로그인한 경우 자동으로 계정 선택 시도
    LaunchedEffect(Unit) {
        isSignedIn = !viewModel.getIDToken().isNullOrEmpty()
        if (isSignedIn) return@LaunchedEffect

        isLoading = true
        BottomSheetSignIn(
            webClientId = BuildConfig.GIS_CLIENT_ID,
            context = context,
        ) { exception, idToken ->
            isLoading = false
            when {
                idToken != null -> {
                    viewModel.saveIDToken(idToken)
                    isSignedIn = true
                }
                exception is NoCredentialException -> { /* 저장된 계정 없음 — 수동 로그인 대기 */ }
                exception != null -> {
                    scope.launch { snackbarHostState.showSnackbar("로그인 중 오류가 발생했습니다.") }
                }
            }
        }
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            // 앱 이름 — 화면 중앙
            Column(
                modifier = Modifier.align(Alignment.Center),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Two Eyes",
                    style = MaterialTheme.typography.displayMedium,
                    textAlign = TextAlign.Center,
                )
                Spacer(Modifier.height(8.dp))
                Text(
                    text = "두 시선이 만나는 곳",
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                )
            }

            // 하단 버튼 영역
            Column(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 40.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                // 로딩 중
                AnimatedVisibility(visible = isLoading, enter = fadeIn(), exit = fadeOut()) {
                    CircularProgressIndicator(modifier = Modifier.size(36.dp))
                }

                // Sign In With Google 버튼
                AnimatedVisibility(visible = !isLoading && !isSignedIn, enter = fadeIn(), exit = fadeOut()) {
                    SignInWithGoogleButton {
                        isLoading = true
                        scope.launch {
                            signIn(
                                request = buildGoogleSignInRequest(),
                                context = context,
                            ) { exception, idToken ->
                                isLoading = false
                                when {
                                    idToken != null -> {
                                        viewModel.saveIDToken(idToken)
                                        isSignedIn = true
                                    }
                                    exception is NoCredentialException -> {
                                        viewModel.clearIDToken()
                                        scope.launch { snackbarHostState.showSnackbar("등록된 Google 계정이 없습니다.") }
                                    }
                                    exception is GetCredentialCancellationException -> { /* 사용자가 취소 — 아무것도 하지 않음 */ }
                                    else -> {
                                        scope.launch { snackbarHostState.showSnackbar("로그인에 실패했습니다. 다시 시도해주세요.") }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Sign In With Google 버튼 UI

@Composable
private fun SignInWithGoogleButton(onClick: () -> Unit) {
    Image(
        painter = painterResource(id = R.drawable.siwg_button),
        contentDescription = "Sign in with Google",
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .clickable(onClick = onClick)
    )
}

// MARK: - Google Credential Manager 헬퍼

@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
private fun buildGoogleSignInRequest(): GetCredentialRequest {
    val option = GetSignInWithGoogleOption
        .Builder(serverClientId = BuildConfig.GIS_CLIENT_ID)
        .setNonce(generateSecureRandomNonce())
        .build()
    return GetCredentialRequest.Builder().addCredentialOption(option).build()
}

// 저장된 계정으로 자동 로그인 시도 (LaunchedEffect 에서 사용)
@SuppressLint("NewApi")
private suspend fun BottomSheetSignIn(
    webClientId: String,
    context: Context,
    completionHandler: (Exception?, String?) -> Unit,
) {
    val option = GetGoogleIdOption.Builder()
        .setFilterByAuthorizedAccounts(true)
        .setServerClientId(webClientId)
        .setNonce(generateSecureRandomNonce())
        .build()
    val request = GetCredentialRequest.Builder().addCredentialOption(option).build()
    signIn(request, context, completionHandler)
}

// 공통 Credential Manager 요청 실행
@SuppressLint("NewApi")
suspend fun signIn(
    request: GetCredentialRequest,
    context: Context,
    completionHandler: (Exception?, String?) -> Unit,
) {
    // delay 는 초기 실행 시 NoCredentialException 을 방지하기 위해 필요
    delay(250)
    try {
        val credential = CredentialManager.create(context)
            .getCredential(request = request, context = context)
            .credential

        if (credential is GoogleIdTokenCredential) {
            Log.i(TAG, "Sign in Successful!")
            completionHandler(null, credential.idToken)
        } else {
            completionHandler(IllegalStateException("Unexpected credential type: ${credential::class}"), null)
        }

    } catch (e: NoCredentialException) {
        Log.e(TAG, "Sign in failed: No credentials found", e)
        completionHandler(e, null)
    } catch (e: GetCredentialCancellationException) {
        Log.i(TAG, "Sign in cancelled by user")
        completionHandler(e, null)
    } catch (e: GoogleIdTokenParsingException) {
        Log.e(TAG, "Sign in failed: GoogleIdToken parsing error", e)
        completionHandler(e, null)
    } catch (e: GetCredentialCustomException) {
        Log.e(TAG, "Sign in failed: Custom credential exception", e)
        completionHandler(e, null)
    } catch (e: Exception) {
        Log.e(TAG, "Sign in failed: ${e.message}", e)
        completionHandler(e, null)
    }
}

// 보안 nonce 생성
@RequiresApi(Build.VERSION_CODES.O)
fun generateSecureRandomNonce(byteLength: Int = 32): String {
    val randomBytes = ByteArray(byteLength)
    SecureRandom.getInstanceStrong().nextBytes(randomBytes)
    return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes)
}

// MARK: - Preview

@SuppressLint("NewApi")
@Preview(showBackground = true)
@Composable
private fun LoginScreenPreview() {
    MaterialTheme {
        // Preview 에서는 실제 로그인 동작 없이 레이아웃만 확인
        Box(Modifier.fillMaxSize()) {
            Column(
                modifier = Modifier.align(Alignment.Center),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text("Two Eyes", style = MaterialTheme.typography.displayMedium)
                Spacer(Modifier.height(8.dp))
                Text(
                    "두 시선이 만나는 곳",
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Column(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 40.dp)
            ) {
                Image(
                    painter = painterResource(id = R.drawable.siwg_button),
                    contentDescription = "Sign in with Google",
                    modifier = Modifier.fillMaxWidth().height(56.dp)
                )
            }
        }
    }
}
