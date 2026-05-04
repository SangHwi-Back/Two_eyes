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
        // LoginViewModel.signInWithApple() 이 delegate 를 설정하고 signInWorker 를 호출함
        // 성공 시 _userData flow 가 갱신되고 위 collect 를 통해 self.userData 가 업데이트됨
        viewModel.signInWithApple()
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() {
        Task { @MainActor in
            do {
                let result = try await viewModel.signInWorker.signInWithGoogle(credential: "")
                PlatformSecureStorage().putObject(key: "GoogleUserData", value: result)
                self.userData = result
            } catch {
                self.errorStatus = .init(
                    providerIdentifier: .google,
                    error: error as? KotlinException
                )
            }
        }
    }
    
    // MARK: - Check Status
    
    func checkStatus(_ identifier: ProviderIdentifier) async throws -> LoginStatusCheckResult? {
        switch identifier {
        case .apple:
            return try await viewModel.appleCheckStatus()
        case .google:
            return try await viewModel.googleCheckState()
        default:
            return LoginStatusCheckResult.NotImplementedYet(identifier: identifier)
        }
    }
}
