//
//  RootView.swift
//  iosApp
//
//  Created by 백상휘 on 10/6/26.
//

import SwiftUI
import Shared

struct RootView: View {
    private let root: RootComponent

    @StateValue
    private var active: Config

    init(_ root: RootComponent) {
        self.root = root
        _active = StateValue(root.active)
    }

    @State private var showLogin = false

    var body: some View {
        TabView {
            switch active {
            case let child as RootComponentChildFeed:
                FeedTabContentView(component: child.component, showLogin: $showLogin)
            case let child as RootComponentChildPickImage:
                PickImageTabContentView(component: child.component, showLogin: $showLogin)
            case let child as RootComponentChildUpload:
                UploadTabContentView(component: child.component, showLogin: $showLogin)
            default:
                EmptyView()
            }
        }
    }
}
