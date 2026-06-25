package com.example.twoeyesproject

import android.annotation.SuppressLint
import android.app.Activity
import androidx.activity.compose.LocalActivity
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
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.credentials.exceptions.GetCredentialCancellationException
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.platformspecific.LoginStatusCheckResult
import com.example.twoeyesproject.platformspecific.SecureUserData
import com.example.twoeyesproject.platformspecific.putGoogleUserData

@SuppressLint("NewApi")
@Composable
fun LoginScreen(
    modifier: Modifier = Modifier,
    onLoginSuccess: () -> Unit = {},
) {
    val activity: Activity = LocalActivity.current!!

    // ViewModel은 remember로 직접 생성 (lifecycle-viewmodel-compose 미사용 시)
    val viewModel = remember { LoginViewModel(activity) }

    var isLoading by remember { mutableStateOf(false) }
    val snackBarHostState = remember { SnackbarHostState() }

    val userData by viewModel.userData.collectAsState()
    val errorStatus by viewModel.errorStatus.collectAsState()

    // 로그인 성공 → 화면 전환
    LaunchedEffect(userData) {
        if (userData != null) {
            isLoading = false
            onLoginSuccess()
        }
    }

    // 로그인 오류 → 스낵바
    LaunchedEffect(errorStatus) {
        val status = errorStatus ?: return@LaunchedEffect
        isLoading = false
        snackBarHostState.showSnackbar("로그인 중 오류가 발생했습니다. ${status.description}")
    }

    // 앱 시작 시 이미 로그인한 경우 자동으로 계정 선택 시도
    LaunchedEffect(Unit) {
        try {
            isLoading = true
            (viewModel.googleCheckState(BuildConfig.GIS_CLIENT_ID) as? LoginStatusCheckResult.Authorized)?.let {
                (it.userInfo as? SecureUserData.GoogleUserData)?.let { googleUserData ->
                    viewModel.storage.putGoogleUserData(googleUserData)
                    onLoginSuccess()
                }
            }
        } catch (_: GetCredentialCancellationException) {
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
                    color = Color(AppColors.TextPrimary),
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
                AnimatedVisibility(visible = !isLoading, enter = fadeIn(), exit = fadeOut()) {
                    SignInWithGoogleButton {
                        isLoading = true
                        viewModel.signInWithGoogle(BuildConfig.GIS_CLIENT_ID)
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
                    color = Color(AppColors.TextPrimary)
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
