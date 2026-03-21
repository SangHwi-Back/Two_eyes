//
//  CameraMergingViewModel.swift
//  TwoEyes
//
//  Created by 백상휘 on 3/20/26.
//

import UIKit
import Combine

class CameraMergingViewModel {
    
    private(set) var imageViewZPositions: [ImageOrder] = [.top, .bottom]
    private let observer: Observer
    private let merger: ImageMerger = .init()
    
    private let initialStatus: [CameraImageViewStatus]
    private var status: [CameraImageViewStatus]
    
    private let mergeSubject = PassthroughSubject<Void, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    init(_ observer: Observer, initialStatus: [CameraImageViewStatus]) {
        self.observer = observer
        self.initialStatus = initialStatus
        self.status = initialStatus
        
        mergeSubject
            .debounce(for: .milliseconds(16), scheduler: DispatchQueue.global())
            .sink { [weak self] in self?.triggerMerge() }
            .store(in: &cancellables)
    }
    
    func swapZPosition() {
        imageViewZPositions.swapAt(0, 1)
        observer.didEffect(.onSwapZPosition(imageViewZPositions))
        mergeSubject.send()
    }
    
    private func triggerMerge() {
        var images = [UIImage]()
        var sizes = [CGSize]()
        
        for stat in status {
            guard let image = stat.image else { continue }
            images.append(image)
            sizes.append(stat.frame.size)
        }
        
        let result = merger.merge(.init(images: images, sizes: sizes))
        
        for (i, image) in result.enumerated() {
            status[i].image = image
        }
        
        observer.didEffect(.onStatusChanged(status))
    }
    
    func callEffectInitialStatus() {
        observer.didEffect(.onCallInitialStatus(initialStatus))
    }
    
    func updatePosition(at index: Int, position: CGPoint) {
        status[index].frame.origin = position
        mergeSubject.send()
    }
    
    protocol Observer { func didEffect(_ effect: Effect) }
    enum ImageOrder { case top, bottom }
    enum Effect {
        case onCallInitialStatus([CameraImageViewStatus])
        case onSwapZPosition([ImageOrder])
        case onStatusChanged([CameraImageViewStatus])
    }
}

struct CameraImageViewStatus {
    var image: UIImage?
    var frame: CGRect
}
