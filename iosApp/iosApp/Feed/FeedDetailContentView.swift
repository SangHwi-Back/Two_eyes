import SwiftUI
import Shared

struct FeedDetailContentView: View {
    @State private var wrapper: FeedDetailComponentWrapper

    init(component: FeedDetailComponent) {
        _wrapper = State(initialValue: FeedDetailComponentWrapper(component: component))
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
