package com.example.twoeyesproject.overlay.component

import com.example.twoeyesproject.platformspecific.SecureUserData

interface LoginComponent {
    fun onConfirm(userData: SecureUserData)
    fun onCancel()
}