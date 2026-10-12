//
//  FeedSearchContentView.swift
//  iosApp
//
//  Created by 백상휘 on 10/10/26.
//

import SwiftUI
import Shared

struct FeedSearchContentView: View {
    @State private var wrapper: FeedSearchComponentWrapper
    @State private var query = ""
    @State private var isSearchActive = false
    @State private var searchResults: [String] = []
    @State private var featuredResults: [String] = []
    
    init(component: FeedSearchComponent) {
        _wrapper = State(initialValue: FeedSearchComponentWrapper(component: component))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(AppColors.shared.Background.color)
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    TextField("Search", text: $query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            isSearchActive = true
                        }
                    
                    Button(action: {
                        if !query.isEmpty {
                            query = ""
                            isSearchActive = false
                        } else {
                            wrapper.onBackClick()
                        }
                    }) {
                        Image(systemName: query.isEmpty ? "arrow.left" : "xmark")
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(AppColors.shared.Surface2.color)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 16)
                
                if query.isEmpty && featuredResults.isEmpty {
                    // Featured feeds grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                        ForEach(featuredResults, id: \.self) { item in
                            FeedSearchResultViewFrom(item: item)
                                .onTapGesture {
                                    // Navigate to feed detail
                                }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    // Search results list
                    List(searchResults, id: \.self) { item in
                        FeedSearchResultViewFrom(item: item)
                            .onTapGesture {
                                // Navigate to feed detail
                            }
                    }
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(AppColors.shared.Surface.color, for: .navigationBar)
        .onAppear {
            // Load featured feeds on appear
            loadFeaturedFeeds()
        }
    }
    
    private func loadFeaturedFeeds() {
        // Implementation to fetch featured feeds
        // This would call the shared ViewModel or API
    }
}

// MARK: - Feed Search Result View
struct FeedSearchResultViewFrom: View {
    let item: String // This should be replaced with proper model
    
    var body: some View {
        HStack(spacing: 8) {
            // Thumbnail placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: thumbnailWidth, height: thumbnailHeight)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Author : \(item)")
                    .font(.title2)
                    .lineLimit(1)
                
                Text("IsLiked : false")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Likes : 0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Replies : 0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(AppColors.shared.Surface2.color)
        .cornerRadius(8)
    }
}
