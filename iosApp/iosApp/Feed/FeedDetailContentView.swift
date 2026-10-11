import SwiftUI
import Shared

struct FeedDetailContentView: View {
    @State private var wrapper: FeedDetailComponentWrapper
    @Binding private var stack: ChildStack<AnyObject, any FeedTabComponentChild>

    init(component: FeedDetailComponent, stack: Binding<ChildStack<AnyObject, any FeedTabComponentChild>>) {
        _wrapper = State(initialValue: FeedDetailComponentWrapper(component: component))
        _stack = stack
    }

    var body: some View {
        ScrollView {
            if let item = wrapper.feedItem {
                FeedItemView(model: item) { type in
                    switch type {
                    case .like:
                        wrapper.onLikeClick()
                    }
                }
            }
        }
        .background(AppColors.shared.Background.color)
    }
}
