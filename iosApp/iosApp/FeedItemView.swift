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

    @State var showReply: Bool

    init(model: FeedItemModel) {
        self.model = model
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
            
            HStack(spacing: 18) {
                Button("", systemImage: "heart") {}
                    .tint(Color.primary)
                Button("", systemImage: "arrowshape.turn.up.left") {}
                    .tint(Color.primary)
                Button("", systemImage: "square.and.arrow.up") {}
                    .tint(Color.primary)
                Spacer()
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
