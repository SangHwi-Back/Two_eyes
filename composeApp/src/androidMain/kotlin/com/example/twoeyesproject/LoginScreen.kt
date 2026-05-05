package com.example.twoeyesproject

import android.annotation.SuppressLint
import android.os.Build
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
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import com.example.twoeyesproject.platformspecific.LoginStatusCheckResult
import com.example.twoeyesproject.platformspecific.SecureUserData
import com.example.twoeyesproject.platformspecific.putGoogleUserData
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import kotlinx.coroutines.launch

@SuppressLint("NewApi")
@Composable
fun LoginScreen(
    modifier: Modifier = Modifier,
    onLoginSuccess: () -> Unit = {},
) {
    val activity = LocalActivity.current

    // ViewModel은 remember로 직접 생성 (lifecycle-viewmodel-compose 미사용 시)
    val viewModel = remember { LoginViewModel(activity) }
    val scope = rememberCoroutineScope()

    var isLoading by remember { mutableStateOf(false) }
    var isSignedIn by remember { mutableStateOf(false) }
    val snackBarHostState = remember { SnackbarHostState() }

    // 앱 시작 시 이미 로그인한 경우 자동으로 계정 선택 시도
    LaunchedEffect(Unit) {
        try {
            isLoading = true
            (viewModel.googleCheckState() as? LoginStatusCheckResult.Authorized)?.let {
                (it.userInfo as? SecureUserData.GoogleUserData)?.let { googleUserData ->
                    viewModel.storage.putGoogleUserData(googleUserData)
                    onLoginSuccess()
                }
            }
        } catch (e: Exception) {
            snackBarHostState.showSnackbar("로그인 중 오류가 발생했습니다. ${e.toString()}")
        } finally {
            isLoading = false
        }
    }

    Scaffold(
        modifier = modifier,
        snackbarHost = { SnackbarHost(snackBarHostState) }
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
                        scope.launch {
                            try {
                                isLoading = true
                                val googleUserData = viewModel.signInWorker.signInWithGoogle(BuildConfig.GIS_CLIENT_ID)
                                viewModel.storage.putGoogleUserData(googleUserData)
                                onLoginSuccess()
                            } catch (_: androidx.credentials.exceptions.GetCredentialCancellationException) {
                            } catch (e: Exception) {
                                snackBarHostState.showSnackbar("로그인 중 오류가 발생했습니다. ${e.toString()}")
                            } finally {
                                isLoading = false
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
