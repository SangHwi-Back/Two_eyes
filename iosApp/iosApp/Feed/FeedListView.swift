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
    @Environment(\.userData) var userData
    
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
        .onChange(
            of: userData.wrappedValue,
            initial: true
        ) { oldValue, newValue  in
            if let newValue, newValue != oldValue {
                viewModel.getAllFeeds()
            }
        }
    }
}

enum FeedListViewTapType { case like }

extension TwoEyesUserData: Equatable {
    static func == (lhs: TwoEyesUserData, rhs: TwoEyesUserData) -> Bool {
        switch lhs {
        case .apple(let L_appleUserData):
            switch rhs {
            case .apple(let R_appleUserData):
                return L_appleUserData == R_appleUserData
            case .google(_):
                return false
            }
        case .google(let L_googleUserData):
            switch rhs {
            case .apple(_):
                return false
            case .google(let R_googleUserData):
                return L_googleUserData == R_googleUserData
            }
        }
    }
}

#Preview {
    FeedListView(apiClient: .init())
}
