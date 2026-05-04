//
//  LoginView+AuthenticationServices.swift
//  iosApp
//
//  Created by SangHwiBack on 4/27/26.
//

import SwiftUI
import AuthenticationServices

//class AppleAuthorizationControllerDelegate: NSObject, ASAuthorizationControllerDelegate {
//    @Binding var errorStatus: LoginErrorStatus?
//    
//    init(errorStatus: Binding<LoginErrorStatus?>) {
//        self._errorStatus = errorStatus
//    }
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
//        self.errorStatus = .init(provider: .apple, error: error)
//    }
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        switch authorization.credential {
//        case let appleCredential as ASAuthorizationAppleIDCredential:
//            try? KeychainModel<AppleUserData>().saveItem(.init(credential: appleCredential))
//        case let passwordCredential as ASPasswordCredential:
//            try? KeychainModel<AppleUserData>().saveItem(.init(credential: passwordCredential))
//        default:
//            return
//        }
//    }
//}
//
//class AppleAuthorizationControllerUIContext: NSObject, ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        // MARK: WANRNING!
//        let window = UIApplication.shared.connectedScenes.first as! UIWindowScene
//        let anchor = ASPresentationAnchor(windowScene: window)
//        return anchor
//    }
//}
