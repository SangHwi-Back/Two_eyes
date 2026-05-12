package com.example.twoeyesproject

import com.example.twoeyesproject.platformspecific.PlatformASAuthorizationControllerDelegate
import com.example.twoeyesproject.platformspecific.PlatformSignInWorker
import com.example.twoeyesproject.platformspecific.SecureUserData
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue
import kotlin.test.fail

class PlatformSignInWorkerTest {
    val signInWorker = PlatformSignInWorker(null).apply {
        isTest = true
    }

    // Android에서 signInWithApple은 no-op.
    // callback(authorizationHandler)이 호출되지 않음을 확인.
    @Test
    fun `signIn with apple is no-op on Android`() {
        var callbackInvoked = false
        val delegate = PlatformASAuthorizationControllerDelegate().apply {
            authorizationHandler = { callbackInvoked = true }
        }
        signInWorker.signInWithApple(delegate)
        assertFalse(callbackInvoked, "Android signInWithApple should not invoke authorizationHandler")
    }

    // 빈 credential → IllegalStateException 발생 → 실패 케이스 확인
    @Test
    fun `signIn with google fails with empty credential`() = runTest {
        try {
            signInWorker.signInWithGoogle("")
            fail("Expected exception with empty credential, but succeeded")
        } catch (e: Exception) {
            assertTrue(true, "Exception expected for empty credential")
        }
    }

    // 비어있지 않은 credential → 성공, 반환된 userData non-null 확인
    @Test
    fun `signIn with google succeeds with valid credential`() = runTest {
        val userData: SecureUserData.GoogleUserData = signInWorker.signInWithGoogle("TEST_CREDENTIAL")
        assertNotNull(userData, "userData should not be null on success")
    }
}
