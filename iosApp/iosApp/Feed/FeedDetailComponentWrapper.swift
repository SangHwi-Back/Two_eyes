import SwiftUI
import Shared

@Observable
class FeedDetailComponentWrapper {
    let component: FeedDetailComponent
    
    private(set) var feedItem: FeedItemModel?
    
    typealias FeedItemCollector = MergeCollector<FeedItemModel?>
    
    init(component: FeedDetailComponent) {
        self.component = component
        
        component.feedItem.collect(collector: FeedItemCollector { [weak self] item in
            self?.feedItem = item
        }) { _ in }
    }
    
    func onBackClick() {
        component.onBackClick()
    }
    
    func onLikeClick() {
        component.onLikeClick()
    }
}
