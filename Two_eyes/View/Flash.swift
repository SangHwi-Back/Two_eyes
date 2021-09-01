//
//  Flash.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/09/01.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

class FlashMessage {
    
    var vc: UIViewController!
    var message: String!
    
    init(_ vc: UIViewController, message: String) {
        self.vc = vc
        self.message = message
    }
    
    func makeMessageView() -> UILabel {
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 16, y: vc.view.frame.height - 130), size: CGSize(width: vc.view.frame.width - 32, height: 52)))
        label.text = message
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .lightGray
        label.alpha = 0.0
        
        return label
    }
    
    func show() {
        
        let label = self.makeMessageView()
        self.vc.view.addSubview(label)
        
        UIView.animateKeyframes(withDuration: 2.8, delay: 0.0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                label.alpha = 0.75
            }
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 2.8) {
                label.alpha = 0.0
            }
        })
    }
}
