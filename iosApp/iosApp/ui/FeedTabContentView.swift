//
//  FeedTabContentView.swift
//  iosApp
//
//  Created by 백상휘 on 10/10/26.
//
import SwiftUI
import Shared

struct FeedTabContentView: View {
    private let component: FeedTabComponent
    private let feedComponent: FeedComponent
    
    @StateValue var stack: ChildStack<AnyObject, any FeedTabComponentChild>
    
    var detail: FeedDetailComponent?
    
    init(component: FeedTabComponent) {
        self.component = component
        let stackValue = StateValue(component.stack)
        _stack = stackValue
        
//        let feedChild = component.stack.value.active.instance as? FeedTabComponentChildFeed
        let items = component.stack.value.items
        let feedChild = items.compactMap {
            $0.instance as? FeedTabComponentChildFeed
        }.first
        
        guard let feedChild else {
            fatalError("FeedTabComponent의 초기 active child는 항상 Feed여야 합니다.")
        }
        
        self.feedComponent = feedChild.component
    }
    
    private var pathBinding: Binding<[FeedTabPathElement]> {
        Binding(
            get: {
                Array(stack.items.dropFirst()).enumerated().compactMap { index, item in
                    switch item.instance {
                    case let c as FeedTabComponentChildFeedDetail:
                        return .detail(id: index, component: c.component)
                    case let c as FeedTabComponentChildFeedSearch:
                        return .search(id: index, component: c.component)
                    default:
                        return nil
                    }
                }
            },
            set: { newPath in
                let popCount = self.pathBinding.wrappedValue.count - newPath.count
                if popCount > 0 {
                    for _ in 0..<popCount {
                        if let elem = component as? TabComponentElement {
                            TabComponentElementKt.onBackClicked(elem)
                        }
                    }
                }
            }
        )
    }
    
    var body: some View {
        NavigationStack(path: pathBinding) {
            FeedContentView(component: feedComponent)
                .navigationDestination(for: FeedTabPathElement.self) { element in
                    switch element {
                    case .detail(_, let component):
                        FeedDetailContentView(component: component, stack: $stack)
                    case .search(_, let component):
                        FeedSearchContentView(component: component, stack: $stack)
                    }
                }
        }
    }
}

private enum FeedTabPathElement: Hashable {
    case detail(id: Int, component: FeedDetailComponent)
    case search(id: Int, component: FeedSearchComponent)
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.detail(l, _), .detail(r, _)):
            return l == r
        case let (.search(l, _), .search(r, _)):
            return l == r
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .detail(let id, _):
            hasher.combine(id)
            hasher.combine(0)
        case .search(let id, _):
            hasher.combine(id)
            hasher.combine(1)
        }
    }
}
