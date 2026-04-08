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
        (viewModel.listData as? [FeedItemModel]) ?? []
    }
    
    var body: some View {
        LazyVStack {
            ForEach(listData, id: \.self) { data in
                FeedItemView(model: data)
            }
        }
    }
}

#Preview {
    FeedListView()
}
