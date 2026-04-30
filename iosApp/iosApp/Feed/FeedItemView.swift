//
//  FeedItemView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/8/26.
//

import SwiftUI
import shared

struct FeedItemView: View {
    let model: FeedItemModel
    let onTapGesture: (FeedListViewTapType) -> Void

    @Namespace var namespace
    @State var showReply: Bool

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
            
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) {
                    GlassIconButton(systemName: "heart") {
                        onTapGesture(.like)
                    }
                    .glassEffectID("feed", in: namespace)
                    GlassIconButton(systemName: "arrowshape.turn.up.left") {
                        onTapGesture(.comment)
                    }
                    .glassEffectID("feed", in: namespace)
                    GlassIconButton(systemName: "square.and.arrow.up") {
                        onTapGesture(.share)
                    }
                    .glassEffectID("feed", in: namespace)
                }
            }
            .padding(.bottom)
            .padding(.leading)
            
            HStack(alignment: .top, spacing: 18) {
                Text(model.author)
                    .font(.callout)
                Text(model.description_)
                    .font(.subheadline)
                Spacer()
            }
            .padding(.bottom)
            .padding(.leading)
            
            HStack {
                Button(showReply ? "Hide Comment" : "Show Comment") {
                    showReply.toggle()
                }
                .tint(Color.secondary)
                .padding(.leading)
                Spacer()
            }
            
            if showReply {
                Text("Comment Area~~~~")
            }
        }
    }
}
