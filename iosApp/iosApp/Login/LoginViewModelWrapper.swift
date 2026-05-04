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
            .collect(collector: MergeCollector<LoginViewErrorStatus?> { status in
                self.errorStatus = status
            }) { _ in }
        
        self.viewModel
            .userData
            .collect(collector: MergeCollector<SecureUserData?> { status in
                if let status {
                    self.userData = status
                }
                else {
                    self.userData = nil
                }
            }) { _ in }
    }
    
    func checkStatus(_ identifier: ProviderIdentifier) async throws -> LoginStatusCheckResult? {
        switch identifier {
        case .apple:
            let result = try await viewModel.appleCheckStatus()
            return result
        case .google:
            let result = try await viewModel.googleCheckState()
            return result
        default:
            return LoginStatusCheckResult.NotImplementedYet(identifier: identifier)
        }
    }
    
    func signInWithApple() {
        viewModel.signInWorker
            .signInWithApple(delegate: viewModel)
    }
    func signInWithGoogle() {
        // TODO: Need to implement
    }
}
