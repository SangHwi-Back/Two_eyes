//
//  FeedItemView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/8/26.
//

import SwiftUI
import Shared

struct FeedItemView: View {
    let model: FeedItemModel
    let onTapGesture: (FeedListViewTapType) -> Void

    @Namespace var namespace
    @State var showReply: Bool
    @State var replyText: String = ""

    init(model: FeedItemModel, onTapGesture: @escaping (FeedListViewTapType) -> Void) {
        self.model = model
        self.onTapGesture = onTapGesture
        self.showReply = model.showReply
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(model.imageUrls, id: \.self) { url in
                        DownloadImageView(url: URL(string: url))
                    }
                }
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.visible, axes: .horizontal)
            .aspectRatio(1, contentMode: .fit)
            .padding(.bottom)
            .padding(.horizontal)
            
            HStack(alignment: .top, spacing: 8) {
                Text(model.author)
                    .font(.callout)
                    .foregroundStyle(AppColors.shared.TextPrimary.color)
                    .frame(minWidth: 100, maxWidth: 140)
                Text(model.description_)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.shared.TextPrimary.color)
                Spacer()
            }
            .padding(.bottom)
            .padding(.horizontal)
            
            HStack {
                GlassEffectContainer(spacing: 8) {
                    HStack(spacing: -2) {
                        GlassIconButton(systemName: "heart") {
                            onTapGesture(.like)
                        }
                        .glassEffectID("feed", in: namespace)
                    }
                }
                
                Spacer()
            }
            .padding(.bottom)
            .padding(.horizontal)
            
            TextField("Comment...", text: $replyText)
                .textFieldStyle(.plain)
                .padding()
                .glassEffect(.regular, in: .capsule)
                .padding(.bottom)
                .padding(.horizontal)
            
            HStack {
                Button(showReply ? "Hide Comment" : "Show Comment") {
                    showReply.toggle()
                }
                .tint(AppColors.shared.Secondary.color)
                .padding(.leading)
                Spacer()
            }
            
            if showReply {
                VStack(alignment: .leading) {
                    ForEach(model.replyArray, id: \.replyId) { model in
                        HStack {
                            Image(systemName: "arrow.turn.down.right")
                                .resizable()
                                .frame(width: 15, height: 15, alignment: .center)
                                .foregroundStyle(AppColors.shared.Divider.color)
                            Text(model.author)
                                .font(.headline)
                                .foregroundStyle(AppColors.shared.TextPrimary.color)
                                .frame(minWidth: 80, maxWidth: 120)
                            Text(model.description_)
                                .font(.footnote)
                                .foregroundStyle(AppColors.shared.TextPrimary.color)
                        }
                    }
                }
            }
        }
    }
}
