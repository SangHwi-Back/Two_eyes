//
//  FilterGestureRecognizer.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/08/23.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import UIKit

extension FilterImageView {
    func actionPanGesture(recognize gesture: UIPanGestureRecognizer, in canvas: UIView, completionHandler: (()->Void)? = nil) {
        
        DispatchQueue.main.async { [self] in
            
            let translation = gesture.translation(in: self)
            self.center = CGPoint(
                x: self.getChangedX(from: self, as: translation, canvas: canvas),
                y: self.getChangedY(from: self, as: translation, canvas: canvas)
            )
            
            gesture.setTranslation(CGPoint.zero, in: self) //initialize
            
            completionHandler?()
        }
    }
    
    func actionPinchGesture(recognize gesture: UIPinchGestureRecognizer, in canvas: UIView, completionHandler: (()->Void)? = nil) {
        
        DispatchQueue.main.async {
            
            if gesture.scale * self.frame.width <= canvas.frame.width {
                self.transform = self.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            }
            
            gesture.scale = 1.0 //initialize
            
            completionHandler?()
        }
    }
    
    func getChangedX(from view: UIImageView, as translation: CGPoint, canvas: UIView) -> CGFloat {
        // view가 가로로 반 이상 잘리면 더 이상 이동 불가
        if view.center.x + translation.x <= 0 { // 왼쪽
            return view.center.x
        } else if view.center.x + translation.x >= canvas.frame.width { // 오른쪽
            return view.center.x
        } else {
            return view.center.x + translation.x
        }
    }
    
    func getChangedY(from view: UIImageView, as translation: CGPoint, canvas: UIView) -> CGFloat {
        // view가 세로로 반 이상 잘리면 더 이상 이동 불가
        if view.center.y + translation.y <= 0 { // 위
            return view.center.y
        } else if view.center.y + translation.y >= canvas.frame.height { // 아래
            return view.center.y
        } else {
            return view.center.y + translation.y
        }
    }
}

extension FilterMainViewController: UIGestureRecognizerDelegate {
    
}

class FilterTapGesutre: UITapGestureRecognizer {
    init(target: Any?, action: Selector?, tapRequired: Int) {
        super.init(target: target, action: action)
        self.numberOfTapsRequired = tapRequired
    }
}
