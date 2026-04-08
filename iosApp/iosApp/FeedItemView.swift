//
//  FeedItemView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/8/26.
//

import SwiftUI
import Shared
import Kingfisher

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
                        KFImage(URL(string: url))
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.visible, axes: .horizontal)
            
            HStack {
                Button("Likes", systemImage: "heart") {
                    
                }
                Button("Comment", systemImage: "arrowshape.turn.up.left") {
                    
                }
                Button("Share", systemImage: "square.and.arrow.up") {
                    
                }
            }
            
            HStack {
                Text(model.author)
                    .font(.largeTitle)
                Text(model.description_)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            HStack {
                Spacer()
                Button(showReply ? "Hide Comment" : "Show Comment") {
                    showReply.toggle()
                }
            }
            
            if showReply {
                Text("Comment Area~~~~")
            }
        }
    }
}

#Preview {
    FeedItemView(model: .init(
        imageUrls: [],
        likes: 0,
        author: "",
        description: "",
        showReply: false
    ))
}
