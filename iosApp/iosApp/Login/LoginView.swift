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
        _wrapper = State(initialValue: LoginViewModelWrapper(viewController: rootViewController))
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // 로그인 오류 표시 — 탭하면 닫힘
            if let errorStatus = wrapper.errorStatus {
                switch errorStatus.providerIdentifier {
                case .apple:
                    GlassIconTitleButton(systemName: "apple.logo", title: errorStatus.description) {
                        withAnimation(.easeOut(duration: 2.0)) {
                            wrapper.errorStatus = nil
                        }
                    }
                case .google:
                    GlassIconTitleButton(title: errorStatus.description) {
                        withAnimation(.easeOut(duration: 2.0)) {
                            wrapper.errorStatus = nil
                        }
                    }
                default:
                    EmptyView()
                }
            }
            
            // Apple 로그인 버튼
            Button {
                wrapper.signInWithApple()
            } label: {
                HStack {
                    Image(systemName: "apple.logo")
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
            
            // Google 로그인 버튼
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
        // Apple Sign In 완료 시 _userData flow → wrapper.userData 변경 → 자동 dismiss
        .onChange(of: wrapper.userData) { _, newValue in
            guard let newValue else { return }
            if let appleData = newValue as? SecureUserData.AppleUserData {
                userData.wrappedValue = .apple(appleData)
            } else if let googleData = newValue as? SecureUserData.GoogleUserData {
                userData.wrappedValue = .google(googleData)
            }
            dismiss()
        }
    }
    
    // 앱 시작 시 저장된 Apple 자격증명이 여전히 유효한지 확인
    private func checkAppleStatus() async {
        do {
            let result = try await wrapper.checkStatus(.apple)
            
            if result is LoginStatusCheckResult.Authorized {
                // 유효하면 저장소에서 데이터를 읽어 앱 상태 갱신 후 dismiss
                if let stored = PlatformSecureStorage().getObject(key: "AppleUserData") as? SecureUserData.AppleUserData {
                    userData.wrappedValue = .apple(stored)
                }
                dismiss()
            }
        } catch {
            wrapper.errorStatus = .init(
                providerIdentifier: .apple,
                error: error as? KotlinException
            )
        }
    }
}
