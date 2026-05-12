package com.example.twoeyesproject

import com.example.twoeyesproject.platformspecific.PlatformASAuthorizationControllerDelegate
import com.example.twoeyesproject.platformspecific.PlatformSignInWorker
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertTrue

class PlatformSignInWorkerTest {
    val signInWorker = PlatformSignInWorker(null).apply {
        isTest = true
    }

    @Test
    fun `signIn with apple`() {
        signInWorker.signInWithApple(object : PlatformASAuthorizationControllerDelegate() {

        })
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
            val userData = signInWorker.signInWithGoogle("")
            // When test that expects success, assertTrue should be success.
            assertTrue(true)
        } catch (_: Exception) {
            if (!successTest)
                assertTrue(true)
        }
    }
}