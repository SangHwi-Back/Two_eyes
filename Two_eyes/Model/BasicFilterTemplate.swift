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
    
    /*
     * preFilteredImage = filteredImage에 Filter효과를 주기 위한 변수이다.
     *                    UIImage를 부여하면 Filter된 filteredImage:UIImage?에서 결과를 확인할 수 있다.
     *                    그러므로 반드시 filterName에 필터 이름을 부여해야 한다.
     * preAdjustingImage = filteredImage에 각종 Attribute를 adjust하여 새로운 이미지를 추출하기 위한 변수이다.
     *                     UIImage를 부여하면 미리 부여된 adjustKey와 adjustValue를 이용하여 이미지를 수정한다.
     *                     filteredImage:UIImage?에서 결과를 확인할 수 있다.
     *                     그러므로 반드시 adjustKey와 adjustValue에 값을 부여해놓아야 한다.
     */
    
    var preFilteredImage: UIImage? {
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
    var preAdjustedImage: UIImage? {
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
    var filteredImage: UIImage?
    
    var adjustKey: String = ""
    var adjustValue: Float = 0.0
    var blurAdjustVal: Float = 0.0
    var brightnessAdjustVal: Float = 0.0
    var contrastAdjustVal: Float = 0.0
    var opacityAdjustVal: Float = 0.0
    
    let blurFilter = CIFilter(name: "CIGaussianBlur")
    let brightnessFilter = CIFilter(name: "CIExposureAdjust")
    let contrastFilter = CIFilter(name: "CIToneCurve")
    let grayscaleFilter = CIFilter(name: "CIPhotoEffectTonal")
}

extension BasicFilterTemplate {
    //filter를 바꿀때마다 이미지에 필터를 적용해준다.
    func filterChange(as image: UIImage?, for filter: String) -> UIImage? {
        guard filter != "none" && filter != "" else { return image }
        
        if let safeImage = image?.fixOrientation(), let ciImage = CIImage(image: safeImage), let ciFilter = CIFilter(name: filter) {
            ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
            ciFilter.setValue(1.0, forKey: kCIInputIntensityKey)
            if let filterOutput = ciFilter.outputImage {
                return UIImage(ciImage: filterOutput)
            } else {
                print("filteredImage에 적용할 새로운 이미지를 만들지 못했음.")
                return nil
            }
        }else{
            print("preFilteredImage에 이미지가 적용되지 않았음.")
            return nil
        }
    }
    
    func adjustingValueChange(as image: UIImage?, using adjustKey: String, for adjustVal: Float) -> UIImage? {
        guard adjustKey != "" && adjustVal != 0.0 && image != nil else { return image }
        
        switch adjustKey {
            case "blur":
                blurAdjustVal = adjustVal
                return blurChange(using: adjustVal, image: image!)
            case "brightness":
                brightnessAdjustVal = adjustVal
                return brightnessChange(using: adjustVal, image: image!)
            case "contrast":
                contrastAdjustVal = adjustVal
                return contrastChange(using: adjustVal, image: image!)
            case "grayScale":
                return grayScaleChange()
            case "opacity":
                opacityAdjustVal = adjustVal
                return opacityChange(using: adjustVal, image: image!)
            default:
                return image
        }
        
    }
    
    func adjustingValueInitiate(_ capturedImage: UIImage?) -> Bool {
        guard capturedImage != nil else { return false }
        
        blurAdjustVal = 0.0
        brightnessAdjustVal = 0.0
        contrastAdjustVal = 0.0
        opacityAdjustVal = 0.0
        
        filteredImage =
            (filterName == "none" || filterName == "") ? capturedImage : filterChange(as: capturedImage, for: filterName)
        
        return true
    }
    
    //아래 메소드들은 모두 이미지의 요소를 조절할때마다 실행한다.
    func blurChange(using adjustVal: Float, image: UIImage?) -> UIImage? {
        if let preFilteredImage = image, let safeCIImage = CIImage(image: preFilteredImage) {
            blurFilter?.setValue(safeCIImage, forKey: kCIInputImageKey)
            blurFilter?.setValue(blurAdjustVal, forKey: kCIInputRadiusKey)
            
            if let filterOutput = blurFilter?.outputImage {
                return UIImage(ciImage: filterOutput)
            }else{
                print("Error in blurChange()")
                return nil
            }
        }else{
            print("Error in blurChange()")
            return nil
        }
    }

    func brightnessChange(using adjustVal: Float, image: UIImage?) -> UIImage? {
        if let safeUIImage = image, let safeCIImage = CIImage(image: safeUIImage) {
            let adjustParams: [String : Any] = ["inputImage": safeCIImage, "inputEV": brightnessAdjustVal]
            brightnessFilter?.setValuesForKeys(adjustParams)
            
            if let filterOutput = brightnessFilter?.outputImage {
                return UIImage(ciImage: filterOutput)
            }else{
                return nil
            }
        }else{
            return nil
        }
    }

    func contrastChange(using adjustVal: Float, image: UIImage?) -> UIImage? {
        var inputPoint0 = CIVector(x:0.0, y:0.0); var inputPoint1 = CIVector(x:0.25, y:0.25); var inputPoint2 = CIVector(x:0.5, y:0.5); var inputPoint3 = CIVector(x:0.75, y:0.75); var inputPoint4 = CIVector(x:1.0, y:1.0)

        switch contrastAdjustVal {
        case 0.00..<0.25:
            inputPoint0 = CIVector(x:CGFloat(adjustVal), y:CGFloat(adjustVal))
        case 0.25..<0.50:
            inputPoint1 = CIVector(x:CGFloat(adjustVal), y:CGFloat(adjustVal))
        case 0.50..<0.75:
            inputPoint2 = CIVector(x:CGFloat(adjustVal), y:CGFloat(adjustVal))
        case 0.75..<1.00:
            inputPoint3 = CIVector(x:CGFloat(adjustVal), y:CGFloat(adjustVal))
        default:
            inputPoint4 = CIVector(x:CGFloat(adjustVal), y:CGFloat(adjustVal))
        }

        contrastFilter?.setDefaults()
        if let safeUIImage = image, let safeCIImage = CIImage(image: safeUIImage) {
            contrastFilter?.setValue(safeCIImage, forKey: kCIInputImageKey)
            contrastFilter?.setValue(inputPoint0, forKey: "inputPoint0")
            contrastFilter?.setValue(inputPoint1, forKey: "inputPoint1")
            contrastFilter?.setValue(inputPoint2, forKey: "inputPoint2")
            contrastFilter?.setValue(inputPoint3, forKey: "inputPoint3")
            contrastFilter?.setValue(inputPoint4, forKey: "inputPoint4")
        }
        
        if let contrastImage = contrastFilter?.outputImage {
            return UIImage(ciImage: contrastImage)
        }else{
            return nil
        }
    }

    func grayScaleChange() -> UIImage? {
        if let safeUIImage = filteredImage, let safeCIImage = CIImage(image: safeUIImage) {
            grayscaleFilter?.setValuesForKeys(["inputImage": safeCIImage])
            if let filterOutput = grayscaleFilter?.outputImage {
                return UIImage(ciImage: filterOutput)
            }else{
                return nil
            }
        } else {
            return nil
        }
    }

    func opacityChange(using adjustVal: Float, image: UIImage?) -> UIImage? {
        opacityAdjustVal = adjustVal
        if let safeUIImage = image {
            UIGraphicsBeginImageContextWithOptions(safeUIImage.size, false, safeUIImage.scale)
            safeUIImage.draw(at: CGPoint.zero, blendMode: .normal, alpha: CGFloat(adjustVal))
            return UIGraphicsGetImageFromCurrentImageContext()
        } else {
            return nil
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
