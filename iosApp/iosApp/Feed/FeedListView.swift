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
    
    @State var errorStatus = PresentingErrorState()
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
                            Task {
                                do {
                                    try await self.viewModel.updateLike(
                                        like: false, feedId: data.feedId)
                                } catch {
                                    self.errorStatus = .init(
                                        isPresenting: true,
                                        error: error
                                    )
                                }
                            }
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
                Task {
                    try? await viewModel.getAllFeeds(page: 1)
                }
            }
        }
        .alert(
            "Error",
            isPresented: $errorStatus.isPresenting,
            presenting: errorStatus.error
        ) { error in
            Button("Close", role: .destructive) {
                self.errorStatus = .init()
            }
        } message: { error in
            Text("작업 중 오류가 발생하였습니다. \(String(describing: error))")
        }
    }
    
    struct PresentingErrorState {
        var isPresenting = false
        var error: (any Error)? = nil
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
