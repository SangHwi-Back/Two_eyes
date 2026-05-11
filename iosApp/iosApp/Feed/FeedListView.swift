//
//  FeedListView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/8/26.
//

import SwiftUI
import Shared
import Intents

struct FeedListView: View {
    var viewModel: FeedListViewModel
    
    @State var isPresenting = false
    
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
                            viewModel.updateLike(like: false, feedId: data.feedId)
                        }
                    }
                }
            }
        }
        .background(AppColors.shared.Background.color)
    }
}

enum FeedListViewTapType { case like }

#Preview {
    FeedListView(apiClient: .init())
}
