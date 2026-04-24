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

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var isPresentedGoogleModal: Bool = false
    @State private var googleUserData: GoogleUserData
    @State private var isGoogleLoggedIn: Bool = false
    
    init(googleUserData: GoogleUserData) {
        self.googleUserData = googleUserData
    }
    
    var body: some View {
        VStack {
            Spacer()
            SignInWithAppleButton { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        // 계정 정보 가져오기
                        let UserIdentifier = appleIDCredential.user
                        let fullName = appleIDCredential.fullName
                        let name =  (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
                        let email = appleIDCredential.email
                        let IdentityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)
                        let AuthorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)
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
            googleCheckState()
            appleCheckState()
        }
        .alert("구글 로그인 실패", isPresented: $isPresentedGoogleModal) {
            Text("확인")
        } message: {
            Text("다시 시도해주세요")
        }

    }
    
    func appleCheckState() {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: "") { credentialState, error in
            guard error == nil else {
                return
            }
            
            switch credentialState {
            case .authorized:
                dismiss()
            default:
                return
            }
        }
    }
    
    func googleCheckState() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                print("Not Sign In")
            } else {
                guard let profile = user?.profile else {
                    return
                }
                
                let data = GoogleUserData(profile: profile)
                googleUserData = data
                isGoogleLoggedIn = true
                
                dismiss()
            }
        }
    }
    
    func googleLogin() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            return
        }
        
        GIDSignIn
            .sharedInstance
            .signIn(withPresenting: presentingViewController) { signInResult, error in
                guard let result = signInResult else {
                    isPresentedGoogleModal = true
                    return
                }
                
                guard let profile = result.user.profile else {
                    return
                }
                
                let data = GoogleUserData(profile: profile)
                googleUserData = data
                isGoogleLoggedIn = true
                
                dismiss()
            }
    }
    
    func googleLogout() {
        GIDSignIn.sharedInstance.signOut()
    }
}

struct GoogleUserData {
    let url: URL?
    let name: String
    let email: String
    
    init(profile: GIDProfileData) {
        self.url = profile.imageURL(withDimension: 180)
        self.name = profile.name
        self.email = profile.email
    }
}

private struct SignInWithGoogleButton: UIViewRepresentable {
    typealias UIViewType = GIDSignInButton
    func makeUIView(context: Context) -> GIDSignInButton {
        GIDSignInButton()
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {}
}
