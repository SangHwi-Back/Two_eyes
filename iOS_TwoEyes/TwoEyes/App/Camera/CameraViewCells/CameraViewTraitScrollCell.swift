//
//  CameraViewTraitScrollCell.swift
//  PhotoApp
//
//  Created by SangHwiBack on 3/6/26.
//

import UIKit
import Combine

class CameraViewTraitScrollCell: UICollectionViewCell {
    
    @IBOutlet weak var plusMinusButton: UIButton!
    @IBOutlet weak var scrollableView: UIView!
    
    private var observing: NSKeyValueObservation?
    let output: PassthroughSubject<CGPoint, Never> = .init()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let gesture = UIPanGestureRecognizer()
        self.observing = gesture.observe(\.state, options: [.new]) { [weak self] recognizer, state in
            guard let view = recognizer.view else {
                return
            }
            
            switch gesture.state {
            case .began, .changed, .ended:
                let velocity = recognizer.velocity(in: view)
                self?.output.send(velocity)
            default:
                return
            }
        }
        scrollableView.addGestureRecognizer(gesture)
    }

}

extension CameraViewTraitScrollCell: CameraViewAdaptiveCell {
    func updateTrailCollection(_ traitCollection: UITraitCollection) {
        
    }
}
