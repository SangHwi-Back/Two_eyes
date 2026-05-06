//
//  LoginViewModelWrapper.swift
//  iosApp
//
//  Created by 백상휘 on 4/30/26.
//

import Foundation
import Shared
import UIKit

@Observable
class LoginViewModelWrapper {
    let viewController: UIViewController?
    
    private var viewModel: LoginViewModel
    
    var errorStatus: LoginViewErrorStatus?
    var userData: SecureUserData?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
        self.viewModel = LoginViewModel(context: viewController)
        
        self.viewModel
            .errorStatus
            .collect(collector: MergeCollector<LoginViewErrorStatus?> { [weak self] status in
                self?.errorStatus = status
            }) { _ in }
        
        self.viewModel
            .userData
            .collect(collector: MergeCollector<SecureUserData?> { [weak self] newValue in
                self?.userData = newValue
            }) { _ in }
    }
    
    // MARK: - Apple Sign In
    
    func signInWithApple() {
        viewModel.signInWithApple()
    }
    
    func signInAppleWithServer(_ apiClient: ApiClient) async -> SecureUserData.AppleUserData? {
        guard let appleData = userData as? SecureUserData.AppleUserData,
              let identityToken = appleData.identityToken
        else {
            return nil
        }
        
        do {
            try await apiClient.appleLogin(
                identityToken: identityToken,
                authorizationCode: appleData.authorizationCode,
                firstName: appleData.givenName,
                lastName: appleData.familyName
            )
            return appleData
        } catch {
            errorStatus = .init(
                providerIdentifier: .apple,
                error: error as? KotlinException
            )
            return nil
        }
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() {
        viewModel.signInWithGoogle(credential: "")
    }
    
    func signInGoogleWithServer(_ apiClient: ApiClient) async -> SecureUserData.GoogleUserData? {
        guard let googleData = userData as? SecureUserData.GoogleUserData,
              let idToken = googleData.idToken
        else {
            return nil
        }
        
        do {
            try await apiClient.googleLogin(
                idToken: idToken)
            return googleData
        } catch {
            errorStatus = .init(
                providerIdentifier: .google,
                error: error as? KotlinException
            )
            return nil
        }
    }
    
    // MARK: - Check Status
    
    func checkStatus(_ identifier: ProviderIdentifier) async throws -> LoginStatusCheckResult? {
        switch identifier {
        case .apple:
            let result = try await viewModel.appleCheckStatus()
            if let result = result as? LoginStatusCheckResult.Authorized,
               let appleUserData = result.userInfo as? SecureUserData.AppleUserData
            {
                PlatformSecureStorage()
                    .putAppleUserData(value: appleUserData)
            }
            return result
        case .google:
            let result = try await viewModel.googleCheckState(credential: "")
            if let result = result as? LoginStatusCheckResult.Authorized,
               let googleUserData = result.userInfo as? SecureUserData.GoogleUserData
            {
                PlatformSecureStorage()
                    .putGoogleUserData(value: googleUserData)
            }
            return result
        default:
            return LoginStatusCheckResult.NotImplementedYet(identifier: identifier)
        }
    }
}
