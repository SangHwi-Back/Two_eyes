package com.example.twoeyesproject.component

import com.arkivanov.decompose.ComponentContext
import com.example.twoeyesproject.platformspecific.SecureUserData

class DefaultLoginComponent(
    val componentContext: ComponentContext,
    val onConfirmed: (SecureUserData) -> Unit,
    val onCanceled: () -> Unit,
) : LoginComponent, ComponentContext by componentContext {
    override fun onConfirm(userData: SecureUserData) {
        onConfirmed(userData)
    }

    override fun onCancel() {
        onCanceled()
    }
}