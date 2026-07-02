//
//  SearchModalView.swift
//  iosApp
//

import SwiftUI
import Shared

struct SearchModalView: View {
    @State private var searchText = ""
    @State private var pendingTab: TabSelection? = nil
    @State private var feedPickerOption = FeedPickerOption.MINE
    @State private var items = [Item]()
    @State private var searchButtonTapped = false {
        didSet {
            // TODO: Search work on viewModel
        }
    }
    
    @Namespace private var namespace
    
    @Binding var tabSelection: TabSelection
    var viewModel: FeedSearchViewModel
    
    var isLoading: Bool {
        (viewModel.isLoading.value as? Bool) ?? false
    }
    
    init(tabSelection: TabSelection, apiClient: ApiClient) {
        self._tabSelection = Binding.constant(tabSelection)
        self.viewModel = FeedSearchViewModel(apiClient: apiClient)
    }
    
    enum FeedPickerOption: Identifiable, CaseIterable {
        case MINE, ALL
        var id: Self { self }
        var title: String {
            switch self {
            case .MINE: return "My Feed"
            case .ALL:  return "All Feed"
            }
        }
    }
    
    var body: some View {
        VStack {
            if searchText.isEmpty {
                VStack(spacing: 0) {
                    Picker("", selection: $feedPickerOption) {
                        ForEach(FeedPickerOption.allCases) {
                            Text($0.title)
                        }
                    }
                    
                    TokenListView("Author", "Contents")
                }
            } else {
                if items.isEmpty {
                    ProgressView()
                        .frame(width: iconWidth, height: iconHeight)
                }
                ItemListView(items)
            }
            
            SearchField()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .background(AppColors.shared.Background.color.ignoresSafeArea())
        .alert("화면을 이동할까요?", isPresented: Binding(
            get: { pendingTab != nil },
            set: { if !$0 { pendingTab = nil } }
        )) {
            Button("확인") {
                if let tab = pendingTab { tabSelection = tab }
                pendingTab = nil
            }
            Button("취소", role: .cancel) {
                pendingTab = nil
            }
        } message: {
            Text("검색어가 지워집니다. 계속 이동하시겠습니까?")
        }
    }
    
    private func TokenListView(_ tokens: String...) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(tokens, id: \.self) { token in
                    Text(token)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func ItemListView(_ items: [Item]) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(items) { item in
                    TwoEyesCard {
                        HStack {
                            PHAssetImage(assetIdentifier: item.imageId)
                            
                            VStack {
                                ItemListTitleText("Author : "+item.author)
                                ItemListContentText("IsLiked : true")
                                ItemListContentText("Likes : 101")
                                ItemListContentText("Replies : 82")
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func ItemListTitleText(_ text: String) -> Text {
        Text(text)
            .font(.headline)
            .foregroundStyle(AppColors.shared.TextPrimary.color)
    }
    
    private func ItemListContentText(_ text: String) -> Text {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(AppColors.shared.TextSecondary.color)
    }
    
    private func SearchField() -> some View {
        HStack(spacing: 12) {
            // 리퀴드 글래스 버튼 그룹
            HStack(spacing: 0) {
                SearchNavButton(icon: "text.below.photo") { requestSwitch(to: .feed) }
                SearchNavButton(icon: "camera")           { requestSwitch(to: .camera) }
                SearchNavButton(icon: "square.and.arrow.up") { requestSwitch(to: .upload) }
            }
            .glassEffect(in: Capsule())
            
            GlassEffectContainer {
                HStack {
                    // 리퀴드 글래스 텍스트필드
                    if searchButtonTapped == false {
                        TextField("Search", text: $searchText)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                            .onKeyPress(.return, action: {
                                guard searchText.isEmpty == false else {
                                    return .ignored
                                }
                                Task {
                                    try? await viewModel.searchFeeds(query: searchText, page: 1)
                                }
                                return .handled
                            })
                            .disabled(isLoading)
                            .glassEffect(in: Capsule())
                            .glassEffectID("search.field", in: namespace)
                    }
                    
                    if searchText.isEmpty == false {
                        
                        SearchNavButton(icon: "magnifyingglass") {
                            withAnimation {
                                searchButtonTapped.toggle()
                            }
                            
                            guard searchText.isEmpty == false else {
                                return
                            }
                            
                            Task {
                                try? await viewModel.searchFeeds(query: searchText, page: 1)
                            }
                        }
                        .disabled(isLoading)
                        .animation(.easeInOut, value: searchText.isEmpty)
                        .glassEffect(in: Circle())
                        .glassEffectID("search.button", in: namespace)
                    }
                }
            }
        }
    }
    
    struct Item: Identifiable {
        var id: ObjectIdentifier {
            ObjectIdentifier(NSString(string: imageId))
        }
        let imageId: String
        let author: String
        let contents: String
    }
    
    private func requestSwitch(to tab: TabSelection) {
        if searchText.isEmpty {
            tabSelection = tab
        } else {
            pendingTab = tab
        }
    }
}

// MARK: - Search Nav Button

struct SearchNavButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .frame(width: 52, height: 48)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }
}
