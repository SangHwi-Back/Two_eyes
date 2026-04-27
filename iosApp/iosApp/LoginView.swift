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

struct LoginErrorStatus {
    let identifier: ProviderIdentifier
    let error: any Error
}

enum LoginStatusCheckResult {
case authorized, needToSignIn(ProviderIdentifier)
}

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.userData) var userData
    
    @State private var isAppleLoggedIn: Bool = false
    @State private var isGoogleLoggedIn: Bool = false
    
    @State private var errorStatus: LoginErrorStatus? = nil
    
    @State private var appleLoginContext: AppleAuthorizationControllerUIContext?
    @State private var appleLoginDelegate: AppleAuthorizationControllerDelegate?
    
    var body: some View {
        VStack {
            Spacer()
            
            if let errorStatus {
                switch errorStatus.identifier {
                case .apple:
                    GlassIconTitleButton(
                        systemName: "apple.logo",
                        title: errorStatus.error.localizedDescription
                    ) {
                        withAnimation(.easeOut(duration: 2.0)) {
                            self.errorStatus = nil
                        }
                    }
                case .google:
                    GlassIconTitleButton(title: errorStatus.error.localizedDescription) {
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
                    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        self.userData.wrappedValue = .apple(
                            AppleUserData(credential: appleIDCredential))
                    }
                case .failure(let error):
                    // Handle error (e.g., user cancelled)
                    print("Auth Error: \(error.localizedDescription)")
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
        .onAppear {
            self.appleLoginContext = .init()
            self.appleLoginDelegate = AppleAuthorizationControllerDelegate(errorStatus: $errorStatus)
        }
        .task {
            await checkStatus()
        }
    }
    
    func checkStatus() async {
        do {
            let appleCredentialStatus = try await appleCheckState()
            
            switch appleCredentialStatus {
            case .authorized:
                dismiss()
            case .needToSignIn(_):
                do {
                    let _ = try await googleCheckState()
                    dismiss()
                } catch let googleError {
                    self.errorStatus = .init(identifier: .google, error: googleError)
                }
            }
        } catch let appleError {
            self.errorStatus = .init(identifier: .apple, error: appleError)
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
        dismiss()
        return .authorized
    }
    
    func appleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        if case .apple(let userData) = userData.wrappedValue {
            request.user = userData.user
        }
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = appleLoginDelegate
        authorizationController.presentationContextProvider = appleLoginContext
        authorizationController.performRequests()
    }
    
    func googleLogin() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            return
        }
        
        GIDSignIn
            .sharedInstance
            .signIn(withPresenting: presentingViewController) { signInResult, error in
                guard let result = signInResult else {
                    errorStatus = .init(identifier: .google, error: error ?? LoginError.unknown)
                    return
                }
                
                guard let profile = result.user.profile else {
                    return
                }
                
                let data = GoogleUserData(profile: profile)
                self.userData.wrappedValue = .google(data)
                isGoogleLoggedIn = true
                
                dismiss()
            }
    }
    
    func googleLogout() {
        GIDSignIn.sharedInstance.signOut()
    }
}

private enum LoginError: LocalizedError {
    case unknown
    
    var errorDescription: String? {
        return "Try again please!"
    }
}

private struct SignInWithGoogleButton: UIViewRepresentable {
    typealias UIViewType = GIDSignInButton
    func makeUIView(context: Context) -> GIDSignInButton {
        GIDSignInButton()
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {}
}
