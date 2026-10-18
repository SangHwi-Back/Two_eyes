//
//  LoginOverlayModifier.swift
//  iosApp
//
//  Created by 백상휘 on 10/18/26.
//

import SwiftUI

/// ViewModifier that manages login overlay visibility based on the component type
struct LoginOverlayModifier: ViewModifier {
    @Binding private var showLogin: Bool
    
    @Binding var overlayView: OverlayView
    
    init(overlayView: Binding<OverlayView>, showLogin: Binding<Bool>) {
        self._overlayView = overlayView
        // Initialize the state based on current component state
        self._showLogin = showLogin
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: _showLogin) {
                LoginView()
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: overlayView) {
                // Update the visibility when component state changes
                switch overlayView {
                case .login:
                    showLogin = true
                default:
                    showLogin = false
                }
            }
    }
}

extension View {
    /// Adds login overlay functionality to a view
    func loginOverlay(overlayView: Binding<OverlayView>, showLogin: Binding<Bool>) -> some View {
        self.modifier(LoginOverlayModifier(overlayView: overlayView, showLogin: showLogin))
    }
}
