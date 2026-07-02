package com.example.twoeyesproject

import androidx.lifecycle.ViewModel

abstract class TwoEyesViewModel : ViewModel() {
    fun emitError(e: TwoEyesException) {
        AppErrorBus.post(e.toUserFacingError())
    }
}

data class UserFacingError(
    val title: String,
    val message: String,
)

fun TwoEyesException.toUserFacingError(): UserFacingError = when (this) {

    is TwoEyesException.Database -> UserFacingError(
        title = "데이터 오류",
        message = if (isDebugBuild) description else "작업에 실패했습니다. 운영팀에 문의하세요."
    )

    is TwoEyesException.Network -> UserFacingError(
        title = "네트워크 오류",
        message = if (isDebugBuild) description else "일시적인 오류가 발생하였습니다."
    )

    is TwoEyesException.Http -> UserFacingError(
        title = "서버 오류 ($statusCode)",
        message = if (isDebugBuild) description else "서버와 통신 중 문제가 발생하였습니다."
    )

    is TwoEyesException.Authentication -> UserFacingError(
        title = "인증 오류",
        message = if (isDebugBuild) description else "다시 로그인해주세요."
    )

    is TwoEyesException.Unknown -> UserFacingError(
        title = "알 수 없는 오류",
        message = if (isDebugBuild) description else "오류가 발생하였습니다."
    )
}
