//
//  GoogleSignInBridgeImpl.swift
//  iosApp
//
//  shared(KMP) 는 GoogleSignIn SDK 를 모른다. SDK 호출은 전부 여기서 하고,
//  shared 가 정의한 GoogleSignInBridge 인터페이스로 결과만 전달한다.
//

import UIKit
import GoogleSignIn
import Shared

final class GoogleSignInBridgeImpl: GoogleSignInBridge {
    func signIn(presenting: UIViewController, callback: GoogleSignInCallback) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
            if let error {
                callback.onResult(user: nil, errorMessage: error.localizedDescription)
                return
            }
            guard let user = result?.user else {
                callback.onResult(user: nil, errorMessage: "Google Sign-in failed")
                return
            }
            callback.onResult(user: user.toGoogleUserData(includeIdToken: true), errorMessage: nil)
        }
    }

    func restorePreviousSignIn(callback: GoogleSignInCallback) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error {
                callback.onResult(user: nil, errorMessage: error.localizedDescription)
                return
            }
            // 복원할 로그인 정보가 없으면 user, errorMessage 모두 nil → NeedToSignIn
            callback.onResult(user: user?.toGoogleUserData(includeIdToken: false), errorMessage: nil)
        }
    }
}

private extension GIDGoogleUser {
    func toGoogleUserData(includeIdToken: Bool) -> SecureUserData.GoogleUserData? {
        guard let profile else { return nil }
        return SecureUserData.GoogleUserData(
            photoUrl: profile.imageURL(withDimension: 180)?.absoluteString,
            name: profile.name,
            givenName: profile.givenName,
            familyName: profile.familyName,
            email: profile.email,
            idToken: includeIdToken ? idToken?.tokenString : nil
        )
    }
}
