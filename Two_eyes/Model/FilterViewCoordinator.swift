//
//  FilterDelegate.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/08/01.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit

//FilterViewController와 AdjustModalViewController가 교환해야할 것
//adjustKey
//adjustValue

class FilterViewCoordinator {
    var modalMasterView: FilterViewController?
    var modalView: AdjustModalViewController!
    var canvasView: UIView?
    var canvasSize: CGSize?
    
    func modalAdjustSliderInitiate() {
        if let modalView = modalView {
            for stackView in modalView.adjustMasterStackView.subviews {
                for case let slider as UISlider in stackView.subviews {
                    slider.value = 0
                }
            }
        }
    }
}
