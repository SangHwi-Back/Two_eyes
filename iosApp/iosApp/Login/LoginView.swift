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
    @Environment(\.userData) var environmentUserData
    @Environment(\.apiClient) var apiClient
    @Environment(\.rootViewController) var rootViewController
    
    @State private var wrapper: LoginViewModelWrapper
    @State private var isLoading = false

    init() {
        let rootViewController = (
            UIApplication.shared.connectedScenes.first as? UIWindowScene
        )?.windows.first?.rootViewController
        
        if let rootViewController {
            _wrapper = State(initialValue: LoginViewModelWrapper(viewController: rootViewController))
        } else {
            fatalError()
        }
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
            
            // 로딩 스피너
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(height: 60)
                    .padding()
                    .transition(.opacity)
            }

            // Apple 로그인 버튼
            if !isLoading {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isLoading = true }
                    wrapper.signInWithApple()
                } label: {
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
                .transition(.opacity)

                // Google 로그인 버튼 — siwg_button 이미지 사용 (.glass 는 maxWidth 무시)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isLoading = true }
                    wrapper.signInWithGoogle()
                } label: {
                    Image("siwg_button")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                        .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                        .cornerRadius(8)
                        .padding()
                }
                .transition(.opacity)
            }
        }
        .onChange(of: wrapper.errorStatus) { _, newValue in
            // 오류가 새로 세팅되면 로딩 해제
            if newValue != nil {
                withAnimation(.easeInOut(duration: 0.2)) { isLoading = false }
            }
        }
        .onChange(of: wrapper.userData) { _, newValue in
            guard let newValue else { return }
            Task {
                defer {
                    withAnimation(.easeInOut(duration: 0.2)) { isLoading = false }
                }
                switch newValue {
                case is SecureUserData.AppleUserData:
                    let userData = await wrapper.signInAppleWithServer(apiClient)
                    if let userData {
                        environmentUserData.wrappedValue = .apple(userData)
                    }
                    dismiss()
                case is SecureUserData.GoogleUserData:
                    let userData = await wrapper.signInGoogleWithServer(apiClient)
                    if let userData {
                        environmentUserData.wrappedValue = .google(userData)
                    }
                    dismiss()
                default:
                    return
                }
            }
        }
    }
}
