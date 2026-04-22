//
//  UploadView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/9/26.
//

import SwiftUI
import Shared
import Photos

private let thumbnailSize: CGSize = CGSize(width: 120, height: 190)
enum UploadableListViewType { case small, large }
enum UploadViewTapType { case delete(MergeResultEntity), upload(MergeResultEntity) }

struct UploadView: View {
    
    @Namespace var namespace
    
    @State var listType = UploadableListViewType.small
    
    private var wrapper: UploadViewModelWrapper
    
    init(database: AppDatabase) {
        wrapper = UploadViewModelWrapper(db: database)
    }
    
    var body: some View {
        List(wrapper.entities, id: \.id) { entity in
            switch listType {
            case .small:
                UploadListSmallCard(entity: entity, onTap: onTap)
            case .large:
                UploadListLargeCard(entity: entity, onTap: onTap)
            }
        }
        .navigationTitle("Upload")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                GlassIconButton(systemName: "list.dash") {
                    listType = .small
                }
                GlassIconButton(systemName: "list.dash.header.rectangle") {
                    listType = .large
                }
            }
        }
        .overlay {
            Text("No Entity enabled")
        }
    }
    
    func onTap(_ tap: UploadViewTapType) {
        switch tap {
        case .delete(let entity):
            wrapper.viewModel.deleteEntity(entity: entity)
        case .upload(let entity):
            wrapper.viewModel.uploadEntity(entity: entity)
        }
    }
}

struct UploadListSmallCard: View {
    let entity: MergeResultEntity
    let onTap: (UploadViewTapType) -> Void
    var body: some View {
        HStack {
            TwoEyesCard {
                HStack {
                    PHAssetImage(assetIdentifier: entity.leadingImageId, size: thumbnailSize)
                    Spacer()
                    Image(systemName: "plus")
                    Spacer()
                    PHAssetImage(assetIdentifier: entity.trailingImageId, size: thumbnailSize)
                    Spacer()
                    Image(systemName: "equal")
                    Spacer()
                    PHAssetImage(assetIdentifier: entity.resultId, size: thumbnailSize)
                }
                .padding()
            }
            
            GlassIconButton(systemName: "trash.circle") {
                onTap(.delete(entity))
            }
            GlassIconButton(systemName: "square.and.arrow.up.circle") {
                onTap(.upload(entity))
            }
        }
        .frame(height: thumbnailSize.height + 20)
    }
}

struct UploadListLargeCard: View {
    let entity: MergeResultEntity
    let onTap: (UploadViewTapType) -> Void
    var body: some View {
        HStack {
            TwoEyesCard {
                HStack {
                    PHAssetImage(assetIdentifier: entity.leadingImageId, size: thumbnailSize * 1.6)
                    Spacer()
                    Image(systemName: "plus")
                    Spacer()
                    PHAssetImage(assetIdentifier: entity.trailingImageId, size: thumbnailSize * 1.6)
                    Spacer()
                    Image(systemName: "equal")
                    Spacer()
                    PHAssetImage(assetIdentifier: entity.resultId, size: thumbnailSize * 1.6)
                }
                .padding()
            }
            
            GlassIconButton(systemName: "trash.circle") {
                onTap(.delete(entity))
            }
            GlassIconButton(systemName: "square.and.arrow.up.circle") {
                onTap(.upload(entity))
            }
        }
        .frame(height: thumbnailSize.height * 1.6 + 20)
    }
}

#Preview {
    UploadView(database: Database_iosKt.getAppDatabase())
}
