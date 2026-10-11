//
//  FeedSearchComponentWrapper.swift
//  iosApp
//
//  Created by 백상휘 on 10/10/26.
//

import SwiftUI
import Shared

@Observable
class FeedSearchComponentWrapper {
    let component: FeedSearchComponent

    init(component: FeedSearchComponent) {
        self.component = component
    }

    func onBackClick() {
        component.onBackClick()
    }
}
