//
//  UploadView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/9/26.
//

import SwiftUI
import Shared

enum UploadableListViewType { case small, large }

struct UploadView: View {
    
    @Environment(\.mergeResultDao) var dao
    
    @State var listType = UploadableListViewType.small
    @State var entities = [MergeResultEntity]()
    
    var body: some View {
        List(entities, id: \.id) { entity in
            switch listType {
            case .small:
                UploadListSmallCard(entity: entity)
            case .large:
                UploadListLargeCard(entity: entity)
            }
        }
        .navigationTitle("Upload")
        .navigationBarTitleDisplayMode(.large)
        .task {
            try? await dao.getAllAsFlow().collect(collector: MergeCollector<[MergeResultEntity]>(callback: { entities in
                self.entities = entities
            }))
        }
    }
}

struct UploadListSmallCard: View {
    let entity: MergeResultEntity
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.shared.Background.color)
                .border(Color.red, width: 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button("", systemImage: "trash.circle") {
                print("")
            }
            .frame(width: 48, height: 48)
            .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 24))
            Button("", systemImage: "square.and.arrow.up.circle") {
                print("")
            }
            .frame(width: 48, height: 48)
            .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 24))
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
    UploadView()
}
