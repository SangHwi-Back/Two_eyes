//
//  UploadViewModelWrapper.swift
//  iosApp
//
//  Created by SangHwiBack on 4/22/26.
//

import Foundation
import Shared

@Observable
class UploadViewModelWrapper {
    let viewModel: UploadViewModel
    
    private(set) var entities = [MergeResultEntity]()
    
    typealias EntityCollector = MergeCollector<[MergeResultEntity]>
    
    init(db: AppDatabase) {
        self.viewModel = UploadViewModel(db: db)
        
        viewModel.mergeEntities.collect(collector: EntityCollector { [weak self] entities in
            self?.entities = entities
        }) { _ in }
    }
}
