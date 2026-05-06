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
    @Environment(\.apiClient) var apiClient
    
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
            Button { wrapper.signInWithApple() } label: {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Sign in with Apple")
                }
                .padding()
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.9))
                .foregroundColor(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .padding()
            }
            
            // Google 로그인 버튼 — siwg_button 이미지 사용 (.glass 는 maxWidth 무시)
            Button { wrapper.signInWithGoogle() } label: {
                Image("siwg_button")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 44)
                    .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                    .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                    .cornerRadius(8)
                    .padding()
            }
        }
        .onChange(of: wrapper.userData) { _, newValue in
            guard let newValue else { return }
            Task {
                switch newValue {
                case is SecureUserData.AppleUserData:
                    await wrapper.signInAppleWithServer(apiClient)
                    dismiss()
                case is SecureUserData.GoogleUserData:
                    await wrapper.signInGoogleWithServer(apiClient)
                    dismiss()
                default:
                    return
                }
            }
        }
    }
}
