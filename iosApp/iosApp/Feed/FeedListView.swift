//
//  FeedListView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/8/26.
//

import SwiftUI
import Shared

struct FeedListView: View {
    var viewModel: FeedListViewModel
    
    var listData: [FeedItemModel] {
        (viewModel.listData.value as? [FeedItemModel]) ?? []
    }
    
    init(apiClient: ApiClient) {
        self.viewModel = .init(apiClient: apiClient)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                ForEach(listData, id: \.self) { data in
                    FeedItemView(model: data) { type in
                        switch type {
                        case .like:
                            viewModel.updateLike(like: false, feedId: "")
                        case .comment:
                            viewModel.updateLike(like: false, feedId: "")
                        case .share:
                            viewModel.updateLike(like: false, feedId: "")
                        }
                    }
                }
            }
        }
    }
}

enum FeedListViewTapType { case like, comment, share }

#Preview {
    FeedListView(apiClient: .init())
}
