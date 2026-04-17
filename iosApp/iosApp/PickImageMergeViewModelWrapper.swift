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
    typealias CameraMergeTarget = PickImageMergeViewModel.CameraMergeTarget
    let observer: Observer
    let viewModel: PickImageMergeViewModel
    
    let mergePublisher: PassthroughSubject<UIImage, Never>
    private(set) var mergedImage: UIImage?
    
    var cancellables = Set<AnyCancellable>()
    
    var leadingTarget: CameraMergeTarget!
    var trailingTarget: CameraMergeTarget!
    
    init(model: PickImageMergeModel) {
        self.observer = Observer()
        let viewModel = PickImageMergeViewModel(
            observer: observer,
            source1: model.leading,
            source2: model.trailing)
        self.viewModel = viewModel
        
        let targets = viewModel.targets.value as! [CameraMergeTarget]
        self.leadingTarget = targets[0]
        self.trailingTarget = targets[1]
        
        self.mergePublisher = PassthroughSubject<UIImage, Never>()
        
        self.viewModel
            .mergeTrigger
            .collect(collector: Collector<UIImage?>(callback: { image in
                if let image {
                    self.mergePublisher.send(image)
                }
            })) { _ in }
        
        self.viewModel
            .targets
            .collect(collector: Collector<[CameraMergeTarget]>(callback: { [weak self] targets in
                self?.leadingTarget = targets[0]
                self?.trailingTarget = targets[1]
            })) { _ in }
        
        self.mergePublisher.sink { image in
            self.mergedImage = image
        }
        .store(in: &cancellables)
    }
    
    class Observer: PickImageMergeViewModelObserver {
        func didStatusChanged(effect: PickImageMergeViewModel.CameraMergeEffectOnStatusChanged) {
            
        }
        
        func didSwapedZPosition(effect: PickImageMergeViewModel.CameraMergeEffectOnSwapZPosition) {
            
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
