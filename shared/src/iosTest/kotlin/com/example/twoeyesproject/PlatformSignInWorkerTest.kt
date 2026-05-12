package com.example.twoeyesproject

import com.example.twoeyesproject.platformspecific.PlatformASAuthorizationControllerDelegate
import com.example.twoeyesproject.platformspecific.PlatformSignInWorker
import com.example.twoeyesproject.platformspecific.SecureUserData
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.fail

class PlatformSignInWorkerTest {
    val signInWorker = PlatformSignInWorker(null).apply {
        isTest = true
    }

    // testSignInWithApple은 동기적으로 authorizationHandler를 호출.
    // 콜백 내부에서 assert하면 runTest가 예외를 잡지 못할 수 있으므로
    // 결과를 변수에 담아 콜백 밖에서 검증.
    @Test
    fun `signIn with apple invokes callback with non-null user`() {
        var receivedUser: SecureUserData.AppleUserData? = null

        val delegate = PlatformASAuthorizationControllerDelegate().apply {
            authorizationHandler = { user -> receivedUser = user }
        }

        signInWorker.signInWithApple(delegate)

        // testSignInWithApple은 동기 호출이므로 delay 없이 바로 확인 가능
        assertNotNull(receivedUser, "authorizationHandler should be invoked with non-null user")
    }

    // 빈 credential → exception (continuation.resumeWithException)
    @Test
    fun `signIn with google fails with empty credential`() = runTest {
        try {
            signInWorker.signInWithGoogle("")
            fail("Expected exception with empty credential, but succeeded")
        } catch (e: Exception) {
            // 예상된 동작
        }
    }

    // 비어있지 않은 credential → 성공, 반환된 userData non-null
    @Test
    fun `signIn with google succeeds with valid credential`() = runTest {
        val userData: SecureUserData.GoogleUserData = signInWorker.signInWithGoogle("TEST_CREDENTIAL")
        assertNotNull(userData, "userData should not be null on success")
    }
}
