package com.example.twoeyesproject

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

fun interface AppErrorCallback {
    fun onError(error: UserFacingError)
}

object AppErrorBus {
    private val _error = MutableStateFlow<UserFacingError?>(null)
    val error: StateFlow<UserFacingError?> = _error.asStateFlow()

    // iOS는 StateFlow 직접 수집이 불가하므로 콜백 인터페이스를 사용
    var callback: AppErrorCallback? = null

    fun post(error: UserFacingError) {
        _error.value = error
        callback?.onError(error)
    }

    fun clear() {
        _error.value = null
    }
}
