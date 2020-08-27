//
//  ModalViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/08/01.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit

class AdjustModalViewController: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    private var modalLabel = UILabel()
    private var slider = UISlider()
    
    private let adjustScrollView = UIScrollView()
    let adjustMasterStackView = UIStackView()
    private let adjustItemsStackView = UIStackView()
    private let doneButton = UIButton()
    private let adjustKey: [String] = Constants.filterViewAdjustKeys
    
    private let coordinator: FilterViewCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .darkGray
        adjustScrollView.delegate = self
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        adjustMasterStackView.translatesAutoresizingMaskIntoConstraints = false
        adjustScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        registerAdjust()
        frameAdjust()
    }
    
    init(coordinator: FilterViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:), AdjustModalViewController.coordinator has not been implemented")
    }
    
    private func frameAdjust() {
        let contentSize = coordinator?.canvasSize ??
            CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height * 0.2) //1번째 실행
        
        //doneButton Attributes Setting
        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = .lightGray
        doneButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        
        //adjustMasterStackView Attributes Setting
        adjustMasterStackView.spacing = 3
        adjustMasterStackView.axis = .vertical
        
        //adjustItemsStackView Attributes Setting
        adjustItemsStackView.axis = .horizontal
        
        //modalLabel Attribute Setting
        modalLabel.frame.size = CGSize(width: contentSize.width * 0.3 - 10,
                                       height: contentSize.height * 0.25)
        
        //slider Attribute Setting
        slider.frame.size = CGSize(width:  adjustItemsStackView.frame.size.width * 0.7 - 10,
                                   height: adjustItemsStackView.frame.size.height * 0.25)
        
        //Add all objects as an hierarchy
        self.view.addSubview(doneButton)
        self.view.addSubview(adjustScrollView)
        adjustScrollView.addSubview(adjustMasterStackView)
        
        //Setting Constraints
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [
            doneButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            doneButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            doneButton.widthAnchor.constraint(equalToConstant: contentSize.width * 0.2),
            doneButton.heightAnchor.constraint(equalToConstant: contentSize.height * 0.1)
        ])//doneButton constraints setting
        
        constraints.append(contentsOf: [
            adjustScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            adjustScrollView.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 10),
            adjustScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            adjustScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10)
        ])//adjustScrollView constraints setting
        
        constraints.append(contentsOf: [
            adjustMasterStackView.leadingAnchor.constraint(equalTo: adjustScrollView.leadingAnchor, constant: 10),
            adjustMasterStackView.topAnchor.constraint(equalTo: adjustScrollView.topAnchor, constant: 10),
            adjustMasterStackView.trailingAnchor.constraint(equalTo: adjustScrollView.trailingAnchor, constant: -10),
            adjustMasterStackView.bottomAnchor.constraint(equalTo: adjustScrollView.bottomAnchor, constant: -10),
            adjustMasterStackView.widthAnchor.constraint(equalToConstant: contentSize.width - 40)
        ])//adjustMasterStackView constraints setting
        //adjustItemsStackView constraints will be set in registerAdjust().
        
        allConstraintsActivate(constraints, activate: true)
    }
    
    private func registerAdjust() {
        for i in 0..<adjustKey.count {
            if let itemsStackView = adjustItemsStackView.copy() as? UIStackView,
                let stackLabel = modalLabel.copy() as? UILabel,
                let stackSlider = slider.copy() as? UISlider {
                
                stackLabel.text = adjustKey[i]
                stackLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: self.view.frame.size.width * 0.3).isActive = true
                stackSlider.tag = i
                stackSlider.isEnabled = true
                stackSlider.addTarget(self, action: #selector(adjustValue), for: .valueChanged)
                
                itemsStackView.addArrangedSubview(stackLabel)
                itemsStackView.addArrangedSubview(stackSlider)
                
                itemsStackView.isLayoutMarginsRelativeArrangement = true
                itemsStackView.layoutMargins = UIEdgeInsets(top: 3, left: 2, bottom: 3, right: 2)
                itemsStackView.distribution = .equalSpacing
                
                adjustMasterStackView.addArrangedSubview(itemsStackView)
            }
        }
    }
    
    private func allConstraintsActivate(_ constraints: [NSLayoutConstraint], activate: Bool) {
        for constraint in constraints {
            constraint.isActive = activate
        }
    }
    
    @objc private func adjustValue(sender: UISlider) {
        DispatchQueue.main.async {
            self.coordinator?.modalMasterView?.adjustValue(sender: sender, self.adjustKey[sender.tag])
        }
    }
    
    @objc func dismissAction() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIView: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! UIView
        } catch {
            print("error in stackView ::: \(error)")
        }
        
        return UIView()
    }
}

