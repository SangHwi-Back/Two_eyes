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
    private let thumbnailSize: CGSize = CGSize(width: 120, height: 190)
    
    let entity: MergeResultEntity
    let viewModel : UploadViewModel
    @State var dto: UploadMergedDTO
    
    init(entity: MergeResultEntity, vm: UploadViewModel) {
        self.entity = entity
        self.viewModel = vm
        self.dto = .init(
            imageIds: [
                entity.leadingImageId,
                entity.trailingImageId,
                entity.resultId
            ].compactMap {
                PHAsset.fetchAssets(withBurstIdentifier: $0, options: nil).firstObject
            },
            tags: [],
            contents: "")
    }
    
    var body: some View {
        ScrollView([.vertical]) { VStack {
            
            TextField("Contents", text: $dto.contents)
            Divider()
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(dto.imageIds, id: \.self) { asset in
                        PHAssetImage(asset: asset, size: thumbnailSize)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.trailing)
                            .onTapGesture {
                                // TODO
                            }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, dto.imageIds.isEmpty ? 8 : 12)
            .frame(height: dto.imageIds.isEmpty ? 0 : thumbnailSize.height)
            
            GlassIconTitleButton(systemName: "square.and.arrow.up.on.square", title: "Confirm") {
                viewModel.uploadEntity(dto: dto)
            }
        }}
        .navigationTitle("Upload")
        .navigationBarTitleDisplayMode(.large)
    }
}
