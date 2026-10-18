import SwiftUI
import Shared

struct FeedContentView: View {
    @State private var wrapper: FeedComponentWrapper

    init(component: FeedComponent) {
        _wrapper = State(initialValue: FeedComponentWrapper(component: component))
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                ForEach(wrapper.items, id: \.self) { item in
                    FeedItemView(model: item) { type in
                        switch type {
                        case .like:
                            wrapper.onLikeClick(feedId: item.feedId)
                        }
                    }
                    .onTapGesture {
                        wrapper.onFeedClick(feedId: item.feedId)
                    }
                }
            }
        }
        .background(AppColors.shared.Background.color)
    }
}
