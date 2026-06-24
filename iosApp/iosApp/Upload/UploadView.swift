//
//  UploadView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/9/26.
//

import SwiftUI
import Shared
import Photos

enum UploadableListViewType { case small, large }
enum UploadViewTapType { case delete, list }

struct UploadView: View {
    @EnvironmentObject var navHost: NavigationPathObject<NavHost.Upload>
    
    @State var listType = UploadableListViewType.small

    // @State로 선언해야 SwiftUI가 부모 재렌더링 시 기존 인스턴스를 보존함
    @State private var wrapper: UploadViewModelWrapper

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    init(database: AppDatabase) {
        _wrapper = State(wrappedValue: UploadViewModelWrapper(db: database))
    }

    var body: some View {
        Group {
            if wrapper.entities.isEmpty {
                Text("No Entities!!")
            } else {
                switch listType {
                case .small:
                    List(wrapper.entities, id: \.id) { entity in
                        UploadListSmallCard(entity: entity) { tapType in
                            onTap(tapType, entity: entity)
                        }
                    }
                case .large:
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(wrapper.entities, id: \.id) { entity in
                                UploadGridCard(entity: entity) { tapType in
                                    onTap(tapType, entity: entity)
                                }
                            }
                        }
                    }
                }
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
    }

    func onTap(_ tap: UploadViewTapType, entity: MergeResultEntity) {
        switch tap {
        case .delete:
            wrapper.viewModel.deleteEntity(entity: entity)
        case .list:
            navHost.push(to: .upload(entity, wrapper.viewModel))
        }
    }
}

struct UploadListSmallCard: View {
    let entity: MergeResultEntity
    let onTap: (UploadViewTapType) -> Void
    var body: some View {
        TwoEyesCard {
            ScrollView(.horizontal) {
                HStack {
                    PHAssetImage(assetIdentifier: entity.leadingImageId, size: thumbnailSize * 0.9)
                    PHAssetImage(assetIdentifier: entity.trailingImageId, size: thumbnailSize * 0.9)
                    PHAssetImage(assetIdentifier: entity.resultId, size: thumbnailSize * 0.9)
                }
                .padding()
            }
        }
        .frame(height: thumbnailSize.height + 20)
        .onTapGesture {
            onTap(.list)
        }
        .overlay(alignment: .topTrailing) {
            GlassIconButton(systemName: "trash.circle") {
                onTap(.delete)
            }
        }
    }
}

struct UploadGridCard: View {
    @Namespace var namespace
    let entity: MergeResultEntity
    let onTap: (UploadViewTapType) -> Void
    var body: some View {
        PHAssetImage(assetIdentifier: entity.resultId, size: thumbnailSize)
            .aspectRatio(1.58, contentMode: .fill)
            .clipped()
            .onTapGesture {
                onTap(.list)
            }
            .overlay(alignment: .topTrailing) {
                GlassIconButton(systemName: "trash.circle") {
                    onTap(.delete)
                }
            }
    }
}

#Preview {
    UploadView(database: Database_iosKt.getAppDatabase())
}
