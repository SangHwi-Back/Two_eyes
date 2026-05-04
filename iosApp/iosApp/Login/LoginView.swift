//
//  LoginView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/24/26.
//

import SwiftUI
import AuthenticationServices
import Shared

struct LoginView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.userData) var userData
    
    @State private var wrapper: LoginViewModelWrapper
    
    init() {
        let rootViewController = (
            UIApplication.shared.connectedScenes.first as? UIWindowScene
        )?.windows.first?.rootViewController
        wrapper = .init(viewController: rootViewController)
    }
    
    fileprivate func checkAppleStatus() async {
        do {
            let result = try await wrapper.checkStatus(.apple)
            if result is LoginStatusCheckResult.Authorized {
                dismiss()
            }
        } catch {
            wrapper.errorStatus = .init(
                providerIdentifier: .apple,
                error: error as? KotlinException
            )
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            if let errorStatus = wrapper.errorStatus {
                switch errorStatus.providerIdentifier {
                case .apple:
                    GlassIconTitleButton(systemName: "apple.logo", title: errorStatus.description) {
                        withAnimation(.easeOut(duration: 2.0)) {
                            self.wrapper.errorStatus = nil
                        }
                    }
                case .google:
                    GlassIconTitleButton(title: errorStatus.description) {
                        withAnimation(.easeOut(duration: 2.0)) {
                            self.wrapper.errorStatus = nil
                        }
                    }
                default:
                    EmptyView()
                }
            }
            Button(action: {
                wrapper.signInWithApple()
            }) {
                HStack {
                    Image(systemName: "applelogo")
                    Text("Sign in with Apple")
                }
                .padding()
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.primary)
                .foregroundColor(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .padding()
            }
            
            GlassIconTitleButton(title: "Google Sign In") {
                wrapper.signInWithGoogle()
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .task {
            await checkAppleStatus()
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
