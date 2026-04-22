//
//  UploadView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/9/26.
//

import SwiftUI
import Shared

enum UploadableListViewType { case small, large }
enum UploadViewTapType { case delete, upload }

struct UploadView: View {
    
    @Environment(\.mergeResultDao) var dao
    
    @Namespace var namespace
    
    @State var listType = UploadableListViewType.small
    @State var entities = [MergeResultEntity]()
    
    private var wrapper: UploadViewModelWrapper
    
    init(database: AppDatabase) {
        wrapper = UploadViewModelWrapper(db: database)
    }
    
    var body: some View {
        List(wrapper.entities, id: \.id) { entity in
            switch listType {
            case .small:
                UploadListSmallCard(entity: entity) { tap in
                    
                }
            case .large:
                UploadListLargeCard(entity: entity)
            }
        }
        .navigationTitle("Upload")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { listType = .small } label: {
                    Image(systemName: "list.dash")
                        .resizable()
                        .scaledToFit()
                        .padding(4)
                        .frame(width: 40, height: 40)
                        .allowsHitTesting(false)
                }
                .buttonStyle(.glass)
                Button { listType = .large } label: {
                    Image(systemName: "list.dash.header.rectangle")
                        .resizable()
                        .scaledToFit()
                        .padding(4)
                        .frame(width: 40, height: 40)
                        .allowsHitTesting(false)
                }
                .buttonStyle(.glass)
            }
        }
        .overlay {
            Text("No Entity enabled")
        }
    }
}

struct UploadListSmallCard: View {
    let entity: MergeResultEntity
    let onTap: (UploadViewTapType) -> Void
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.shared.Background.color)
                .border(Color.red, width: 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            GlassIconButton(systemName: "trash.circle") {
                onTap(.delete)
            }
            GlassIconButton(systemName: "square.and.arrow.up.circle") {
                onTap(.upload)
            }
        }
        .frame(height: 100)
    }
}

struct UploadListLargeCard: View {
    let entity: MergeResultEntity
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .fill(AppColors.shared.Background.color)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button("", systemImage: "trash.circle") {
                print("")
            }
            .frame(width: 48, height: 48, alignment: .center)
            .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 24))
            Button("", systemImage: "square.and.arrow.up.circle") {
                print("")
            }
            .frame(width: 48, height: 48, alignment: .center)
            .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 24))
        }
        .frame(height: 160)
    }
}

#Preview {
    UploadView(database: Database_iosKt.getAppDatabase())
}
