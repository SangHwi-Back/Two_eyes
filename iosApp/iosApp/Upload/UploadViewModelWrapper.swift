//
//  UploadViewModelWrapper.swift
//  iosApp
//
//  Created by SangHwiBack on 4/22/26.
//

import SwiftUI
import Shared

@Observable
class UploadViewModelWrapper {
    let viewModel: UploadViewModel
    
    private(set) var entities = [MergeResultEntity]()
    
    typealias EntityCollector = MergeCollector<[MergeResultEntity]>
    
    init(db: AppDatabase, client: ApiClient) {
        self.viewModel = UploadViewModel(dao: db.getMergeResultDao(), client: client)
        
        viewModel.mergeEntities.collect(collector: EntityCollector { [weak self] entities in
            withAnimation {
                if entities.isEmpty {
                    self?.entities = self?.getTestData() ?? []
                } else {
                    self?.entities = entities
                }
            }
        }) { _ in }
    }
    
    func getTestData() -> [MergeResultEntity] {
        [
            .init(id: 0,
                  resultId: UUID().uuidString, leadingImageId: UUID().uuidString, trailingImageId: UUID().uuidString,
                  name: "Test1", date: "", isUploaded: false),
            .init(id: 1,
                  resultId: UUID().uuidString, leadingImageId: UUID().uuidString, trailingImageId: UUID().uuidString,
                  name: "Test2", date: "", isUploaded: true),
            .init(id: 2,
                  resultId: UUID().uuidString, leadingImageId: UUID().uuidString, trailingImageId: UUID().uuidString,
                  name: "Test3", date: "", isUploaded: false)
        ]
    }
    
    func deleteEntity(_ entity: MergeResultEntity) {
        Task {
            do {
                try await viewModel.deleteEntity(entity: entity)
            } catch {
                print(error)
            }
        }
    }
}
