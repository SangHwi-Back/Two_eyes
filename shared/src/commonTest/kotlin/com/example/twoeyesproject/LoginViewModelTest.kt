package com.example.twoeyesproject

import com.example.twoeyesproject.platformspecific.LoginStatusCheckResult
import com.example.twoeyesproject.platformspecific.ProviderIdentifier
import com.example.twoeyesproject.platformspecific.SecureUserData
import kotlinx.coroutines.test.runTest
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

class LoginViewModelTest {
    val viewModel: LoginViewModel = LoginViewModel(null)

    @BeforeTest
    fun `LoginViewModelTest before test`() {
        viewModel.clearAppleUserData()
        viewModel.clearGoogleUserData()
    }

    @AfterTest
    fun `LoginViewModelTest after test`() {
        assertNull(viewModel.errorStatus.value, "[LoginViewModel] error occurred!")

        viewModel.clearAppleUserData()
        viewModel.clearGoogleUserData()
    }

    @Test
    fun `apple check login status`() = runTest {
        assertEquals(
            LoginStatusCheckResult.NotImplementedYet(ProviderIdentifier.APPLE),
            viewModel.appleCheckStatus(),
            "Need to Implement Apple Login on Android")
    }

    @Test
    fun `google check login status`() = runTest {
        assertEquals(
            LoginStatusCheckResult.NeedToSignIn(ProviderIdentifier.GOOGLE),
            viewModel.googleCheckState(""))
    }

    @Test
    fun `fetch userData`() {
        assertNull(viewModel.getAppleUserData(), "Empty apple user data expected")
        assertNull(viewModel.getGoogleUserData(), "Empty google user data expected")

        viewModel.saveUserData(
            SecureUserData.AppleUserData(
            user = "user",
            password = "password",
            givenName = "givenName",
            familyName = "familyName",
            email = "email",
            identityToken = "identityToken",
            authorizationCode = "authorizationCode"))
        val appleUserData = viewModel.getAppleUserData()
        assertNotNull(appleUserData, "Apple user data expected")
        assertContentEquals(listOf(
            "user", "password", "givenName", "familyName",
            "email", "identityToken", "authorizationCode"
        ), listOf(
            appleUserData.user, appleUserData.password, appleUserData.givenName, appleUserData.familyName,
            appleUserData.email, appleUserData.identityToken, appleUserData.authorizationCode
        ))

        viewModel.saveUserData(
            SecureUserData.GoogleUserData(
            photoUrl = "photoUrl",
            name = "name",
            givenName = "givenName",
            familyName = "familyName",
            email = "email",
            idToken = "idToken"))
        val googleUserData = viewModel.getGoogleUserData()
        assertNotNull(googleUserData, "Google user data expected")
        assertContentEquals(listOf(
            "photoUrl", "name", "givenName",
            "familyName", "email", "idToken"
        ), listOf(
            googleUserData.photoUrl, googleUserData.name, googleUserData.givenName,
            googleUserData.familyName, googleUserData.email, googleUserData.idToken
        ))
    }
}