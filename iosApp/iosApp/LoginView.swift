//
//  LoginView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/24/26.
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift
import GoogleSignIn

enum ProviderIdentifier {
    case apple, google
}

struct LoginErrorStatus: CustomStringConvertible {
    let provider: ProviderIdentifier
    let error: any Error
    
    var description: String {
        "[\(provider)] \(error.localizedDescription)"
    }
}

enum LoginStatusCheckResult: Equatable {
    case authorized,
         needToSignIn(ProviderIdentifier)
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .authorized:
            return rhs == .authorized
        case .needToSignIn(let provider):
            if case .needToSignIn(let rhsProvider) = rhs {
                return provider == rhsProvider
            } else {
                return false
            }
        }
    }
}

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.userData) var userData
    
    @State private var errorStatus: LoginErrorStatus? = nil
    
    var body: some View {
        VStack {
            Spacer()
            
            if let errorStatus {
                switch errorStatus.provider {
                case .apple:
                    GlassIconTitleButton(systemName: "apple.logo", title: errorStatus.description) {
                        withAnimation(.easeOut(duration: 2.0)) {
                            self.errorStatus = nil
                        }
                    }
                case .google:
                    GlassIconTitleButton(title: errorStatus.description) {
                        withAnimation(.easeOut(duration: 2.0)) {
                            self.errorStatus = nil
                        }
                    }
                }
            }
            
            SignInWithAppleButton { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    do {
                        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                            
                            let userData = AppleUserData(credential: appleIDCredential)
                            
                            self.userData.wrappedValue = .apple(userData)
                            try KeychainModel<AppleUserData>().saveItem(userData)
                        }
                        else {
                            throw LoginError.noLoginData
                        }
                    } catch {
                        self.errorStatus = .init(provider: .apple, error: LoginError.unknown)
                    }
                case .failure(let error):
                    self.errorStatus = .init(provider: .apple, error: error)
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .padding()
            
            GoogleSignInButton(
                scheme: .light,
                style: .wide,
                state: .normal
            ) {
                googleLogin()
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .task {
            await checkStatus()
        }
    }
    
    func checkStatus() async {
        switch userData.wrappedValue {
        case .apple(_):
            do {
                let check = try await appleCheckState()
                guard check == .authorized else { return }
                dismiss()
            } catch {
                self.errorStatus = .init(provider: .apple, error: error)
            }
        case .google(_):
            do {
                let check = try await appleCheckState()
                guard check == .authorized else { return }
                dismiss()
            } catch {
                self.errorStatus = .init(provider: .google, error: error)
            }
        default:
            return
        }
    }
    
    func appleCheckState() async throws -> LoginStatusCheckResult {
        guard case .apple(let userData) = userData.wrappedValue else {
            return .needToSignIn(.apple)
        }
        
        let state = try await ASAuthorizationAppleIDProvider()
            .credentialState(forUserID: userData.user)
        
        switch state {
        case .authorized:
            return .authorized
        default:
            return .needToSignIn(.apple)
        }
    }
    
    func googleCheckState() async throws -> LoginStatusCheckResult {
        let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
        
        guard let profile = user.profile else {
            return .needToSignIn(.google)
        }
        
        let data = GoogleUserData(profile: profile)
        self.userData.wrappedValue = .google(data)
        return .authorized
    }
    
    func googleLogin() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            return
        }
        
        GIDSignIn
            .sharedInstance
            .signIn(withPresenting: presentingViewController) { signInResult, error in
                guard let result = signInResult else {
                    errorStatus = .init(provider: .google, error: error ?? LoginError.unknown)
                    return
                }
                
                guard let profile = result.user.profile else {
                    errorStatus = .init(provider: .google, error: LoginError.noLoginData)
                    return
                }
                
                let data = GoogleUserData(profile: profile)
                self.userData.wrappedValue = .google(data)
                
                dismiss()
            }
    }
}

private enum LoginError: LocalizedError {
    case unknown
    case noLoginData
    
    var errorDescription: String? {
        return "Try again please!"
    }
}
