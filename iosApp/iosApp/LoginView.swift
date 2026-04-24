//
//  LoginView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/24/26.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn

struct LoginView: View {
    var body: some View {
        VStack {
            SignInWithAppleButton { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    // Handle successful authentication
                    print("Auth Success: \(authorization)")
                case .failure(let error):
                    // Handle error (e.g., user cancelled)
                    print("Auth Error: \(error.localizedDescription)")
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 45)
            .padding()
            
            SignInWithGoogleButton()
        }
    }
}

private struct SignInWithGoogleButton: UIViewRepresentable {
    typealias UIViewType = GIDSignInButton
    func makeUIView(context: Context) -> GIDSignInButton {
        GIDSignInButton()
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {}
}

#Preview {
    LoginView()
}
