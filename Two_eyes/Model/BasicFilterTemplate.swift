//
//  BasicFilterTemplate.swift
//  CameraExam
//
//  Created by 백상휘 on 2020/02/07.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import Foundation
import UIKit

protocol BasicFilterTemplageDelegate {
    func afterFilterChanged(as image: CIImage, for filterKey: String)
    func afterAdjustingValueChange(as image: CIImage, using adjustKey: FilterAdjustKey, for adjustVal: Float)
}

enum FilterAdjustKey: String, Hashable, CaseIterable {
    static func == (lhs: FilterAdjustKey, rhs: FilterAdjustKey) -> Bool {
        return lhs.desc == rhs.desc
    }
    
    case blur = "Blur"
    case brightness = "Brightness"
    case sepia = "Sepia"
    case vignette = "Vignette"
    case contrast = "Contrast"
    case addBlue = "Blue"
    case addGreen = "Green"
    case addRed = "Red"
    case opacity = "Opacity"
    
    var desc: String {
        get {
            switch self {
            case .blur:
                return "CIGaussianBlur"
            case .brightness:
                return "CIExposureAdjust"
            case .sepia:
                return "CISepiaTone"
            case .vignette:
                return "CIVignette"
            case .contrast:
                return "CIToneCurve"
            case .addBlue, .addGreen, .addRed, .opacity:
                return "CIColorMatrix"
            }
        }
    }
}

class BasicFilterTemplate {
    var delegate: BasicFilterTemplageDelegate?
    var wouldDelegateExecute: Bool = false // 뷰 구성 초기에는 델리게이트 메소드를 실행할 필요가 없기 때문에 실행할지 말지를 관리하는 flag값이 필요함.
    var filterContext: CIContext = CIContext()
    var filterViewAdjustKey: [FilterAdjustKey]!
    
    init(image: CIImage) {
        self.filteredImage = image
        self.filterAdjustedImage = image
        self.filterViewAdjustKey = FilterAdjustKey.allCases
    }
    
    /*
     * preFilteredImage = filteredImage에 Filter효과를 주기 위한 변수이다.
     *                    이 클래스에서 처리되는 모든 이미지는 CIImage로서,
     *                    Delegate 함수인 afterFilterChange(as:,for:) 메소드에서 UIImage 등으로 변경해주어야 한다.
     * preAdjustingImage = filteredImage에 각종 Attribute를 adjust하여 새로운 이미지를 추출하기 위한 변수이다
     *                     이 클래스에서 처리되는 모든 이미지는 CIImage이고, self.filteredImage 를 처리한다.
     *                     preFilteredImage와 마찬가지로 Delegate 함수인
     *                     afterAdjustingValueChange(as:,using:,for:) 메소드에서 UIImage 등으로 변경해주어야 한다.
     */
    
    var needToFilterCIImage: CIImage {
        get {
            return filteredImage
        }
        set(newVal) {
            filteredImage = filterChange(as: newVal, for: filterName)
        }
    }
    var filterName: String = "none"
    var needToAdjustCIImage: CIImage {
        get {
            return filterAdjustedImage
        }
        set(newVal) {
            adjustingValueChange(as: newVal, for: adjustValue)
        }
    }
    var filteredImage: CIImage
    var filterAdjustedImage: CIImage
    
    var adjustKey: FilterAdjustKey = .blur
    var adjustValue: Float = 0.0
    //sepia default value and vignette radius value is 0.0
    private(set) var ciFilterNormalKeyValuePair: [FilterAdjustKey: Float] = [
        .blur: 0.0,
        .brightness: 0.0,
        .sepia: 0.0,
        .vignette: 0.0
    ]
    
    private(set) var contrastFilterValues: [String: CIVector] = [
        "inputPoint0": CIVector(x: 0.0, y: 0.0),
        "inputPoint1": CIVector(x:0.25, y:0.25),
        "inputPoint2": CIVector(x:0.5, y:0.5),
        "inputPoint3": CIVector(x:0.75, y:0.75),
        "inputPoint4": CIVector(x:1, y:1)
    ]
    private(set) var colorFilterValues: [CGFloat] = [0,0,0,0]
    var combinationActivated: Bool = false {
        didSet {
            if combinationActivated {
                self.adjustValue = 0.0
                self.ciFilterNormalKeyValuePair = self.ciFilterNormalKeyValuePair.mapValues ({_ in 0.0})
            }
        }
    }
    
    func admitFilter(to ciImage: CIImage, filtername: String, isAdjust: Bool = true) {
        filterName = filtername
        if isAdjust {
            needToAdjustCIImage = ciImage
        } else {
            needToFilterCIImage = ciImage
        }
        
    }
}

extension BasicFilterTemplate {
    // filter를 바꿀때마다 이미지에 필터를 적용해준다.
    // CIFilter는 mutable. 새로 생성해주는 것이 옳다. 고 한다.
    // View Controller 로부터 받는 image는 UIImage에서 변경 성공한 CIImage이다.
    func filterChange(as image: CIImage, for filterName: String) -> CIImage {
        defer {
            if wouldDelegateExecute {
                delegate?.afterFilterChanged(as: filteredImage, for: filterName)
            }
        }
        
        if let safeCIFilter = CIFilter(name: filterName) {
            safeCIFilter.setValue(image, forKey: kCIInputImageKey)
            if let safeOutputImage = safeCIFilter.outputImage {
                return safeOutputImage
            } else {
                return image
            }
        } else {
            return image
        }
    }
    
    /*
     1. 현재 변경되는 UISlider의 키 값을 이용하여 filteredImage에 필터를 적용한다.
     2. 나머지 필터들 중 이미 적용되어 값이 0.0 보다 클 경우 필터를 추가하여 적용한다.(applyingFilter(_:, parameters:))
     3. CIImage를 반환한다.
     */
    func adjustingValueChange(as image: CIImage, for adjustVal: Float, completionHandler: ((CIImage?)->Void)?=nil) {
        
        DispatchQueue.main.async { [self] in
            let tupleInfo = getFilterTupleInfo(adjustKey, value: adjustVal)
            
            tupleInfo.0.setValue(filteredImage, forKey: kCIInputImageKey)
            var changedImage: CIImage = tupleInfo.0.outputImage!
            
            // 객체에 저장된 Filter Attribute 값을 업데이트합니다.
            if ciFilterNormalKeyValuePair.contains(where: {$0.key == adjustKey}) {
                ciFilterNormalKeyValuePair[adjustKey] = adjustVal
            } else if adjustKey == .contrast {
                
                switch adjustVal {
                case 0.00..<0.25:
                    self.contrastFilterValues.updateValue(CIVector(x: CGFloat(adjustVal), y: CGFloat(adjustVal)), forKey: "inputPoint0")
                case 0.25..<0.50:
                    self.contrastFilterValues.updateValue(CIVector(x: CGFloat(adjustVal), y: CGFloat(adjustVal)), forKey: "inputPoint1")
                case 0.50..<0.75:
                    self.contrastFilterValues.updateValue(CIVector(x: CGFloat(adjustVal), y: CGFloat(adjustVal)), forKey: "inputPoint2")
                case 0.75..<1.00:
                    self.contrastFilterValues.updateValue(CIVector(x: CGFloat(adjustVal), y: CGFloat(adjustVal)), forKey: "inputPoint3")
                default:
                    self.contrastFilterValues.updateValue(CIVector(x: CGFloat(adjustVal), y: CGFloat(adjustVal)), forKey: "inputPoint4")
                }
                
            } else if [.blur, .addGreen, .addRed, .opacity, .blur].contains(adjustKey) {
                switch adjustKey {
                case .addBlue:
                    colorFilterValues[0] = CGFloat(adjustVal)
                case .addGreen:
                    colorFilterValues[1] = CGFloat(adjustVal)
                case .addRed:
                    colorFilterValues[2] = CGFloat(adjustVal)
                default:
                    colorFilterValues[3] = CGFloat(adjustVal)
                }
                
                changedImage = changedImage.applyingFilter(tupleInfo.1, parameters: tupleInfo.2)
            }
            
            // 객체에 저장된 Filter Attribute 값을 이용하여 필터에 이미지를 차례대로 적용한다.
            for dict in ciFilterNormalKeyValuePair {
                if dict.value > 0.0 && dict.key != adjustKey {
                    let restTupleInfo = getFilterTupleInfo(dict.key, value: dict.value)
                    changedImage = changedImage.applyingFilter(restTupleInfo.1, parameters: restTupleInfo.2)
                }
            }
            
            //contrastFilterValues
            for dict in contrastFilterValues {
                if dict.value.x > 0.0 {
                    let restTupleInfo = getFilterTupleInfo(.contrast, value: Float(dict.value.x))
                    changedImage = changedImage.applyingFilter(restTupleInfo.1, parameters: restTupleInfo.2)
                }
            }
            
            //colorFilterValues
            for i in 0...3 {
                if colorFilterValues[i] > 0 {
                    let restTupleInfo = getFilterTupleInfo(.addRed, value: 0)
                    changedImage = changedImage.applyingFilter(restTupleInfo.1, parameters: restTupleInfo.2)
                    break
                }
            }
            
            filterAdjustedImage = changedImage
            completionHandler?(filterAdjustedImage)
            if wouldDelegateExecute {
                delegate?.afterAdjustingValueChange(as: self.filterAdjustedImage, using: adjustKey, for: adjustValue)
            }
        }
    }
    
    /*
     Get Filter's Informations(CIFilter?, String key, Dictionary? parameters) as a Tuple.
     Optional is meaning there is nothing exact key in this function. return (nil, "", nil)
     */
    func getFilterTupleInfo(_ key: FilterAdjustKey, value: Float) -> (CIFilter, String, [String: Any]) {
        switch key {
        case .blur:
            return (CIFilter(name: "CIGaussianBlur")!, "CIGaussianBlur", [kCIInputRadiusKey: ciFilterNormalKeyValuePair[key]!])
        case .brightness:
            return (CIFilter(name: "CIExposureAdjust")!, "CIExposureAdjust", [kCIInputEVKey: ciFilterNormalKeyValuePair[key]!])
        case .contrast:
            switch value {
            case 0.00..<0.25:
                return (CIFilter(name: "CIToneCurve")!, "CIToneCurve", ["inputPoint0": contrastFilterValues["inputPoint0"]!])
            case 0.25..<0.50:
                return (CIFilter(name: "CIToneCurve")!, "CIToneCurve", ["inputPoint1": contrastFilterValues["inputPoint1"]!])
            case 0.50..<0.75:
                return (CIFilter(name: "CIToneCurve")!, "CIToneCurve", ["inputPoint2": contrastFilterValues["inputPoint2"]!])
            case 0.75..<1.00:
                return (CIFilter(name: "CIToneCurve")!, "CIToneCurve", ["inputPoint3": contrastFilterValues["inputPoint3"]!])
            default:
                return (CIFilter(name: "CIToneCurve")!, "CIToneCurve", ["inputPoint4": contrastFilterValues["inputPoint4"]!])
            }
        case .sepia:
            return (CIFilter(name: "CISepiaTone")!, "CISepiaTone", [kCIInputIntensityKey: ciFilterNormalKeyValuePair[key]!])
        case .vignette:
            return (CIFilter(name: "CIVignette")!, "CIVignette", [kCIInputRadiusKey: ciFilterNormalKeyValuePair[key]!, kCIInputIntensityKey: ciFilterNormalKeyValuePair[key]!])
        case .addBlue, .addGreen, .addRed, .opacity:
            return (CIFilter(name: "CIColorMatrix")!, "CIColorMatrix", ["inputAVector": CIVector(values: colorFilterValues, count: 4)])
        }
    }

//    private func grayScaleChange(image: CIImage, forKey: String) -> CIImage {
//        guard let safeCIFilter = CIFilter(name: forKey) else { return image }
//        safeCIFilter.setValue(image, forKey: kCIInputImageKey)
//        if let safeImage = safeCIFilter.outputImage {
//            return safeImage
//        }else{
//            return image
//        }
//    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
}
