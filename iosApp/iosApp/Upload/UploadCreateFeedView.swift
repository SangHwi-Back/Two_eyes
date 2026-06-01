//
//  UploadCreateFeedView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/24/26.
//

import SwiftUI
import Shared
import Photos

struct UploadCreateFeedView: View {
    @Environment(\.apiClient) var apiClient
    @Environment(\.appConstant) var constant
    
    @State var dto: UploadMergedDTO
    
    let entity: MergeResultEntity
    let viewModel : UploadViewModel
    
    init(entity: MergeResultEntity, vm: UploadViewModel) {
        self.entity = entity
        self.viewModel = vm
        self.dto = .init(
            imageIds: [
                entity.leadingImageId,
                entity.trailingImageId,
                entity.resultId
            ],
            tags: [],
            contents: "")
    }
    
    var body: some View {
        ScrollView([.vertical]) { VStack {
            
            TextField("Contents", text: $dto.contents)
            Divider()
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(dto.imageIds, id: \.self) { identifier in
                        let asset = PHAsset.fetchAssets(
                            withLocalIdentifiers: [identifier], options: nil
                        ).firstObject
                        if let asset {
                            PHAssetImage(asset: asset)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.trailing)
                                .onTapGesture {
                                    // TODO
                                }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, dto.imageIds.isEmpty ? 8 : 12)
            .frame(height: dto.imageIds.isEmpty ? 0 : CGFloat(constant.THUMBNAIL_SIZE_HEIGHT))
            
            GlassIconTitleButton(systemName: "square.and.arrow.up.on.square", title: "Confirm") {
                viewModel.uploadEntity(dto: dto)
            }
        }}
        .navigationTitle("Upload")
        .navigationBarTitleDisplayMode(.large)
    }
}
