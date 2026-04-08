//
//  FeedListView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/8/26.
//

import SwiftUI
import Shared

struct FeedListView: View {
    var viewModel = FeedListViewModel()
    
    var listData: [FeedItemModel] {
        (viewModel.listData.value as? [FeedItemModel]) ?? []
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                ForEach(listData, id: \.self) { data in
                    FeedItemView(model: data)
                }
            }
        }
    }
}

#Preview {
    FeedListView()
}
