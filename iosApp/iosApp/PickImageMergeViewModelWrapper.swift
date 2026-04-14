//
//  PickImageMergeViewModelWrapper.swift
//  iosApp
//
//  Created by SangHwiBack on 4/14/26.
//

import Foundation
import UIKit
import Combine
import Shared

@Observable
class PickImageMergeViewModelWrapper {
    let observer: Observer
    let viewModel: MergeViewModel
    
    let mergePublisher: PassthroughSubject<UIImage, Never>
    private(set) var mergedImage: UIImage?
    
    var cancellables = Set<AnyCancellable>()
    
    init(model: PickImageMergeModel) {
        self.observer = Observer()
        self.viewModel = MergeViewModel(
            observer: observer,
            source1: model.leading,
            source2: model.trailing)
        self.mergePublisher = PassthroughSubject<UIImage, Never>()
        
        self.viewModel
            .mergeTrigger
            .collect(collector: Collector<UIImage>(callback: { image in
                self.mergePublisher.send(image)
            })) { _ in }
        
        self.mergePublisher.sink { image in
            self.mergedImage = image
        }
        .store(in: &cancellables)
    }
    
    class Observer: MergeViewModelObserver {
        func didStatusChanged(effect: MergeViewModel.CameraMergeEffectOnStatusChanged) {
            
        }
        
        func didSwapedZPosition(effect: MergeViewModel.CameraMergeEffectOnSwapZPosition) {
            
        }
    }
}

class Collector<T> : Kotlinx_coroutines_coreFlowCollector {
    let callback:(T) -> Void

    init(callback: @escaping (T) -> Void) {
        self.callback = callback
    }
    
    func emit(value: Any?, completionHandler: @escaping (Error?) -> Void) {
        callback(value as! T)
        completionHandler(nil)
    }
}
