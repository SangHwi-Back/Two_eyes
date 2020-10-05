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
    func filterChange(as image: UIImage?, for filter: String)
    func adjustingValueChange(as image: UIImage?, using adjustKey: String, for adjustVal: Float)
}

class BasicFilterTemplate {
    var delegate: BasicFilterTemplageDelegate?
    var wouldDelegateExecute: Bool = true
    var filterContext: CIContext = CIContext()
    
    init(image: UIImage) {
        self.contrastFilter.setValuesForKeys([
            "inputPoint0":CIVector(x: 0.0, y: 0.0),
            "inputPoint1":CIVector(x:0.25, y:0.25),
            "inputPoint2":CIVector(x:0.5, y:0.5),
            "inputPoint3":CIVector(x:0.75, y:0.75),
            "inputPoint4":CIVector(x:1, y:1)
        ])
        self.filteredImage = image
        self.preFilteredImage = image
        self.preAdjustedImage = image
    }
    
    /*
     * preFilteredImage = filteredImage에 Filter효과를 주기 위한 변수이다.
     *                    UIImage를 부여하면 Filter된 filteredImage:UIImage?에서 결과를 확인할 수 있다.
     *                    그러므로 반드시 filterName에 필터 이름을 부여해야 한다.
     * preAdjustingImage = filteredImage에 각종 Attribute를 adjust하여 새로운 이미지를 추출하기 위한 변수이다.
     *                     UIImage를 부여하면 미리 부여된 adjustKey와 adjustValue를 이용하여 이미지를 수정한다.
     *                     filteredImage:UIImage?에서 결과를 확인할 수 있다.
     *                     그러므로 반드시 adjustKey와 adjustValue에 값을 부여해놓아야 한다.
     */
    
    var preFilteredImage: UIImage {
        get {
            return filteredImage
        }
        set(newVal) {
            filteredImage = filterChange(as: newVal, for: filterName)
            if(wouldDelegateExecute) {
                delegate?.filterChange(as: filteredImage, for: filterName)
            }
        }
    }
    var filterName: String = ""
    var preAdjustedImage: UIImage {
        get {
            return filteredImage
        }
        set(newVal) {
            filteredImage = adjustingValueChange(as: newVal, using: adjustKey, for: adjustValue)
            if(wouldDelegateExecute) {
                delegate?.adjustingValueChange(as: newVal, using: adjustKey, for: adjustValue)
            }
        }
    }
    var filteredImage: UIImage
    
    var adjustKey: String = ""
    var adjustValue: Float = 0.0
    var blurAdjustVal: Float = 0.0
    var brightnessAdjustVal: Float = 0.0
    var contrastAdjustVal: Float = 0.0
    var opacityAdjustVal: Float = 0.0
    
    var combinationActivated: Bool = false
    
    let blurFilter = CIFilter(name: "CIGaussianBlur")!
    let brightnessFilter = CIFilter(name: "CIExposureAdjust")!
    var contrastFilter = CIFilter(name: "CIToneCurve")!
    let grayscaleFilter = CIFilter(name: "CIPhotoEffectTonal")!
}

extension BasicFilterTemplate {
    //filter를 바꿀때마다 이미지에 필터를 적용해준다.
    func filterChange(as image: UIImage, for filter: String) -> UIImage {
        guard filter != "none" && filter != "" else { return image }
        
        if let ciImage = CIImage(image: image.fixOrientation()), let ciFilter = CIFilter(name: filter) {
            ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
            ciFilter.setValue(1.0, forKey: kCIInputIntensityKey)
            if let filterOutput = ciFilter.outputImage {
                return UIImage(ciImage: filterOutput)
            } else {
                print("filteredImage에 적용할 새로운 이미지를 만들지 못했음.")
                return image
            }
        }else{
            print("preFilteredImage에 이미지가 적용되지 않았음.")
            return image
        }
    }
    
    func adjustingValueChange(as image: UIImage, using adjustKey: String, for adjustVal: Float) -> UIImage {
        guard adjustKey != "" else { return image }
        
        switch adjustKey {
            case "blur", "brightness":
                return contextValueChanged(using: adjustVal, image: image, forKey: adjustKey)
            case "contrast":
                return contrastChange(using: adjustVal, image: image)
            case "grayScale":
                return grayScaleChange(image)
            case "opacity":
                return opacityChange(using: adjustVal, image: image) ?? image
            default:
                return image
        }
    }
    
    func getFilter(_ str : String) -> CIFilter? {
        switch str {
        case "blur":
            return self.blurFilter
        case "brightness":
            return self.brightnessFilter
        case "contrast":
            return self.contrastFilter
        case "grayScale":
            return self.grayscaleFilter
        default:
            return nil
        }
    }
    
    func contextValueChanged(using adjustVal: Float, image: UIImage, forKey: String) -> UIImage {
        guard let filter = getFilter(forKey) else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        
        if forKey == "blur" {
            self.blurAdjustVal = adjustVal
            self.filterContext.setValue(adjustVal, forKey: kCIInputRadiusKey)
        } else if forKey == "brightness" {
            self.brightnessAdjustVal = adjustVal
            self.filterContext.setValue(adjustVal, forKey: kCIInputEVKey)
        }
        
        if let result = filter.outputImage, let cgImage = self.filterContext.createCGImage(result, from: result.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            return image
        }
    }

    func contrastChange(using adjustVal: Float, image: UIImage) -> UIImage {
        self.contrastAdjustVal = adjustVal
        self.contrastFilter.setDefaults()
        self.contrastFilter.setValue(image, forKey: kCIInputImageKey)
        
        var key = ""
        let value = CIVector(x:CGFloat(adjustVal), y:CGFloat(adjustVal))
        
        switch contrastAdjustVal {
        case 0.00..<0.25:
            key = "inputPoint0"
        case 0.25..<0.50:
            key = "inputPoint1"
        case 0.50..<0.75:
            key = "inputPoint2"
        case 0.75..<1.00:
            key = "inputPoint3"
        default:
            key = "inputPoint4"
        }
        
        self.contrastFilter.setValue(value, forKey: key)
        if let contrastImage = contrastFilter.outputImage {
            return UIImage(ciImage: contrastImage)
        } else {
            return image
        }
    }

    func grayScaleChange(_ image: UIImage) -> UIImage {
        self.grayscaleFilter.setValue(image, forKey: kCIInputImageKey)
        if let filterOutput = grayscaleFilter.outputImage {
            return UIImage(ciImage: filterOutput)
        }else{
            return image
        }
    }

    func opacityChange(using adjustVal: Float, image: UIImage) -> UIImage? {
        self.opacityAdjustVal = adjustVal
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(at: CGPoint.zero, blendMode: .normal, alpha: CGFloat(self.opacityAdjustVal))
        return UIGraphicsGetImageFromCurrentImageContext()
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
