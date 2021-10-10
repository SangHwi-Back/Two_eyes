//
//  BasicFilterTemplate.swift
//  CameraExam
//
//  Created by 백상휘 on 2020/02/07.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import Foundation
import UIKit
import CoreImage.CIFilterBuiltins

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
    var adjustFilters = [String: CIFilter]()
    
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
    
    private(set) var ciFilterNormalKeyValuePair = [FilterAdjustKey: Float]()
    private(set) var contrastFilterValues = [String: CIVector]()
    private(set) var colorFilterValues = [String: CIVector]()
    
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
    
    func filterInitiate() {
        filterName = "none"
        adjustKey = .blur
        adjustValue = 0.0
        contrastFilterValues.removeAll()
        colorFilterValues.removeAll()
        ciFilterNormalKeyValuePair.removeAll()
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
        
        switch adjustKey {
        case .blur, .brightness, .sepia, .vignette:
            ciFilterNormalKeyValuePair.updateValue(adjustVal, forKey: adjustKey)
            break
        case .contrast:
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
            break
        case .addRed, .addGreen, .addBlue, .opacity:
            switch adjustKey {
            case .addRed:
                colorFilterValues.updateValue(CIVector(x: CGFloat(1-adjustVal), y: 0, z: 0, w: 0), forKey: "inputRVector")
            case .addGreen:
                colorFilterValues.updateValue(CIVector(x: 0, y: CGFloat(1-adjustVal), z: 0, w: 0), forKey: "inputGVector")
            case .addBlue:
                colorFilterValues.updateValue(CIVector(x: 0, y: 0, z: CGFloat(1-adjustVal), w: 0), forKey: "inputBVector")
            case .opacity:
                colorFilterValues.updateValue(CIVector(x: 0, y: 0, z: 0, w: CGFloat(1-adjustVal)), forKey: "inputAVector")
            default:
                return
            }
        }
        
        DispatchQueue.main.async { [self] in
            
            var resultImage: CIImage? = image
            var param = [String: Any]()
            
            for item in ciFilterNormalKeyValuePair {
                
                param.removeAll()
                param[kCIInputImageKey] = resultImage
                
                switch item.key {
                case .blur:
                    param[kCIInputRadiusKey] = item.value; break;
                case .brightness:
                    param[kCIInputEVKey] = item.value; break;
                case .sepia:
                    param[kCIInputIntensityKey] = item.value; break;
                case .vignette:
                    param[kCIInputRadiusKey] = item.value
                    param[kCIInputIntensityKey] = item.value; break;
                default:
                    continue
                }
                
                resultImage = CIFilter(name: item.key.desc, parameters: param)?.outputImage
                if resultImage == nil { print("warn!!!") }
            }
            
            for item in contrastFilterValues {
                param.removeAll()
                param[kCIInputImageKey] = resultImage
                param[item.key] = item.value
                resultImage = CIFilter(name: "CIToneCurve", parameters: param)?.outputImage
                if resultImage == nil { print("warn!!!") }
            }
            
            for item in colorFilterValues {
                param.removeAll()
                param[kCIInputImageKey] = resultImage
                param[item.key] = item.value
                resultImage = CIFilter(name: "CIColorMatrix", parameters: param)?.outputImage
                if resultImage == nil { print("warn!!!") }
            }
            
            if let resultImage = resultImage {
                
                filterAdjustedImage = resultImage
                completionHandler?(filterAdjustedImage)
                if wouldDelegateExecute {
                    delegate?.afterAdjustingValueChange(as: self.filterAdjustedImage, using: adjustKey, for: adjustValue)
                }
            }
        }
    }
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
