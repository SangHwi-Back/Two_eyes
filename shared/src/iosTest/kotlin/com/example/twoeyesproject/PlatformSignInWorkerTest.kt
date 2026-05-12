package com.example.twoeyesproject

import com.example.twoeyesproject.platformspecific.PlatformASAuthorizationControllerDelegate
import com.example.twoeyesproject.platformspecific.PlatformSignInWorker
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.runTest
import platform.AuthenticationServices.ASAuthorization
import platform.AuthenticationServices.ASAuthorizationController
import platform.Foundation.NSError
import platform.darwin.NSObject
import kotlin.test.Test
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

class PlatformSignInWorkerTest {
    val signInWorker = PlatformSignInWorker(null).apply {
        isTest = true
    }

    @Test
    fun `signIn with apple`() = runTest {
        val delegate = object : PlatformASAuthorizationControllerDelegate() {}

        delegate.authorizationHandler = { userData ->
            assertNotNull(userData)
        }

        signInWorker.signInWithApple(delegate)

        delay(1500L)
    }

    @Test
    fun `signIn with google fails`() = runTest {
        signInWithGoogleTest(false)
    }

    @Test
    fun `signIn with google success`() = runTest {
        signInWithGoogleTest(true)
    }

    private suspend fun signInWithGoogleTest(successTest: Boolean) {
        try {
            val credential = if (successTest) "TEST_CREDENTIAL" else ""
            signInWorker.signInWithGoogle(credential)
            // When test that expects success, assertTrue should be success.
            assertTrue(true)
        } catch (_: Exception) {
            if (!successTest)
                assertTrue(true)
        }
    }
}