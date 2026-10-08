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
    private var stack: ChildStack<AnyObject, RootComponentChild>

    init(_ root: RootComponent) {
        self.root = root
        _stack = StateValue(root.stack)
    }

    var body: some View {
        switch stack.active.instance {
        case let child as RootComponentChildFeed:
            FeedContentView(component: child.component)
        case let child as RootComponentChildFeedDetail:
            FeedDetailContentView(component: child.component)
        default:
            EmptyView()
        }
    }
}
