//
//  LoginOverlayModifier.swift
//  iosApp
//
//  Created by 백상휘 on 10/18/26.
//

import SwiftUI

/// ViewModifier that manages login overlay visibility based on the component type
struct LoginOverlayModifier: ViewModifier {
    @State private var isShowingLogin = false
    
    @Binding var overlayView: OverlayView
    
    init(overlayView: Binding<OverlayView>) {
        self._overlayView = overlayView
        // Initialize the state based on current component state
        self._isShowingLogin = State(initialValue: overlayView.wrappedValue == .login)
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isShowingLogin) {
                LoginView()
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: overlayView) {
                // Update the visibility when component state changes
                switch overlayView {
                case .login:
                    isShowingLogin = true
                default:
                    isShowingLogin = false
                }
            }
    }
}

extension View {
    /// Adds login overlay functionality to a view
    func loginOverlay(overlayView: Binding<OverlayView>) -> some View {
        self.modifier(LoginOverlayModifier(overlayView: overlayView))
    }
}
