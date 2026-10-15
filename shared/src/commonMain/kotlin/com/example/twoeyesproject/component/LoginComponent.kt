package com.example.twoeyesproject.component

import com.example.twoeyesproject.platformspecific.SecureUserData

interface LoginComponent {
    fun onConfirm(userData: SecureUserData)
    fun onCancel()
}