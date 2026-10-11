import SwiftUI
import Shared

@Observable
class FeedComponentWrapper {
    let component: FeedComponent

    private(set) var items = [FeedItemModel]()

    typealias ItemsCollector = MergeCollector<[FeedItemModel]>

    init(component: FeedComponent) {
        self.component = component
        
        component.items.collect(collector: ItemsCollector { [weak self] items in
            self?.items = items
        }) { _ in }
    }

    func onFeedClick(feedId: String) {
        component.onFeedClick(feedId: feedId)
    }

    func onSearchClick() {
        component.onSearchClick()
    }

    func onLikeClick(feedId: String) {
        component.onLikeClick(feedId: feedId)
    }
}
