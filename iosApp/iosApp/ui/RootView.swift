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

    var body: some View {
        TabView {
            switch active {
            case let child as RootComponentChildFeed:
                FeedTabContentView(component: child.component)
            case let child as RootComponentChildPickImage:
                PickImageTabContentView(component: child.component)
            case let child as RootComponentChildUpload:
                UploadTabContentView(component: child.component)
            default:
                EmptyView()
            }
        }
    }
}
