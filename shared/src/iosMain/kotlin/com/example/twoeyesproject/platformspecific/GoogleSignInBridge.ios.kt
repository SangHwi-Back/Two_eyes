package com.example.twoeyesproject.platformspecific

import platform.UIKit.UIViewController

/**
 * GoogleSignIn SDK 는 iOS 앱(Swift, Xcode SPM) 쪽에서만 의존한다.
 * shared 는 이 인터페이스만 알고, 구현은 앱 시작 시 Swift 에서 [GoogleSignInBridgeRegistry] 에 등록한다.
 */
interface GoogleSignInCallback {
    /** 성공이면 [user], 실패면 [errorMessage]. 로그인 정보가 없는 경우(복원 실패)는 둘 다 null. */
    fun onResult(user: SecureUserData.GoogleUserData?, errorMessage: String?)
}

interface GoogleSignInBridge {
    fun signIn(presenting: UIViewController, callback: GoogleSignInCallback)
    fun restorePreviousSignIn(callback: GoogleSignInCallback)
}

object GoogleSignInBridgeRegistry {
    var bridge: GoogleSignInBridge? = null
}
