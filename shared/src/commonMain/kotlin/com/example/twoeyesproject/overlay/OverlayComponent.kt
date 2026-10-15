package com.example.twoeyesproject.overlay

import com.arkivanov.decompose.router.slot.ChildSlot
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.overlay.component.LoginComponent

interface OverlayComponent {
    val slot: Value<ChildSlot<*, OverlaySlot>>
    fun onDismiss() : Boolean
    fun showLogin()
    sealed interface OverlaySlot {
        data class Login(val component: LoginComponent) : OverlaySlot
    }
}