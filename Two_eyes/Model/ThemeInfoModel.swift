//
//  ThemeInfoModel.swift
//  Two_eyes
//
//  Created by 백상휘 on 2021/09/29.
//  Copyright © 2021 Sanghwi Back. All rights reserved.
//

import Foundation
import UIKit

enum ThemeInfoModelColors: String {
    case rootBackgroundViewColor = "rootBackgroundViewColor"
    case navigationBackgroundColor = "navigationBackgroundColor"
    case buttonBackgroundColor = "buttonBackgroundColor"
    case buttonTintColor = "buttonTintColor"
    case labelTintColor = "labelTintColor"
    case textFieldTintColor = "textFieldTintColor"
    case collectionViewBackgroundColor = "collectionViewBackgroundColor"
    case searchBarBackgroundColor = "searchBarBackgroundColor"
}

class ThemeInfoModel {
    
    var defaultKey: String = ""
    
    var rootBackgroundViewColor: UIColor?
    var navigationBackgroundColor: UIColor?
    var buttonBackgroundColor: UIColor?
    var buttonTintColor: UIColor?
    var labelTintColor: UIColor?
    var textFieldTintColor: UIColor?
    var collectionViewBackgroundColor: UIColor?
    var searchBarBackgroundColor: UIColor?
    
    var infoItems: [ThemeInfo]?
    var themeInfo: ThemeInfo? {
        didSet {
            rootBackgroundViewColor = themeInfo?.rootBackgroundViewColor?.toUIColor
            navigationBackgroundColor = themeInfo?.navigationBackgroundColor?.toUIColor
            buttonBackgroundColor = themeInfo?.buttonBackgroundColor?.toUIColor
            buttonTintColor = themeInfo?.buttonTintColor?.toUIColor
            labelTintColor = themeInfo?.labelTintColor?.toUIColor
            textFieldTintColor = themeInfo?.textFieldTintColor?.toUIColor
            collectionViewBackgroundColor = themeInfo?.collectionViewBackgroundColor?.toUIColor
            searchBarBackgroundColor = themeInfo?.searchBarBackgroundColor?.toUIColor
        }
    }
    
    private(set) var defaultThemeInfo: ThemeInfo!
    
    func getColor(_ colorString: String?) -> UIColor {
        return (colorString?.trimmingCharacters(in: CharacterSet(charactersIn: " ")) ?? "") == "" ? .systemBackground : colorString?.toUIColor ?? .systemBackground
    }
    
    func applyTheme(_ info: ThemeInfo) {
        
        guard let theme = infoItems?.filter({$0.themeName == info.themeName}).first else {
            print("chosen theme not found")
            return
        }
        
        themeInfo = theme
        
        UIView.appearance().backgroundColor = rootBackgroundViewColor
        UINavigationBar.appearance().backgroundColor = navigationBackgroundColor
        UIButton.appearance().backgroundColor = buttonBackgroundColor
        UIButton.appearance().tintColor = buttonTintColor
        UILabel.appearance().tintColor = labelTintColor
        UITextField.appearance().tintColor = textFieldTintColor
        UICollectionView.appearance().backgroundColor = collectionViewBackgroundColor
        UITableView.appearance().backgroundColor = collectionViewBackgroundColor
        UISearchBar.appearance().backgroundColor = searchBarBackgroundColor
    }
    
    func setDefaultThemeInfo(themeInfo: [String: UIColor]) {
        
        let themeKeys = themeInfo.keys
        
        defaultThemeInfo = ThemeInfo(themeName: "Default")
        defaultThemeInfo.contents = "Two_eyes 기본 테마입니다.\n 아무런 색이 적용되지 않은 테마입니다."
        
        for key in themeKeys {
            let color = themeInfo[key]
            
            switch key {
            case ThemeInfoModelColors.rootBackgroundViewColor.rawValue:
                defaultThemeInfo.rootBackgroundViewColor = color.toRGBString()
                UIView.appearance().backgroundColor = color
                break
            case ThemeInfoModelColors.navigationBackgroundColor.rawValue:
                defaultThemeInfo.navigationBackgroundColor = color.toRGBString()
                UINavigationBar.appearance().backgroundColor = color
                break
            case ThemeInfoModelColors.buttonBackgroundColor.rawValue:
                defaultThemeInfo.buttonBackgroundColor = color.toRGBString()
                UIButton.appearance().backgroundColor = color
                break
            case ThemeInfoModelColors.buttonTintColor.rawValue:
                defaultThemeInfo.buttonTintColor = color.toRGBString()
                UIButton.appearance().tintColor = color
                break
            case ThemeInfoModelColors.labelTintColor.rawValue:
                defaultThemeInfo.labelTintColor = color.toRGBString()
                UILabel.appearance().tintColor = color
                break
            case ThemeInfoModelColors.textFieldTintColor.rawValue:
                defaultThemeInfo.textFieldTintColor = color.toRGBString()
                UITextField.appearance().tintColor = color
                break
            case ThemeInfoModelColors.collectionViewBackgroundColor.rawValue:
                defaultThemeInfo.collectionViewBackgroundColor = color.toRGBString()
                UICollectionView.appearance().backgroundColor = color
                UITableView.appearance().backgroundColor = color
                break
            case ThemeInfoModelColors.searchBarBackgroundColor.rawValue:
                defaultThemeInfo.searchBarBackgroundColor = color.toRGBString()
                UISearchBar.appearance().backgroundColor = color
                break
            default:
                continue
            }
        }
    }
    
    func setDefaultThemeInfo(themeInfo: ThemeInfo) {
        UIView.appearance().backgroundColor = UIColor(hex: themeInfo.rootBackgroundViewColor)
        UINavigationBar.appearance().backgroundColor = UIColor(hex: themeInfo.navigationBackgroundColor)
        UIButton.appearance().backgroundColor = UIColor(hex: themeInfo.buttonBackgroundColor)
        UIButton.appearance().tintColor = UIColor(hex: themeInfo.buttonTintColor)
        UILabel.appearance().tintColor = UIColor(hex: themeInfo.labelTintColor)
        UITextField.appearance().tintColor = UIColor(hex: themeInfo.textFieldTintColor)
        UICollectionView.appearance().backgroundColor = UIColor(hex: themeInfo.collectionViewBackgroundColor)
        UITableView.appearance().backgroundColor = UIColor(hex: themeInfo.collectionViewBackgroundColor)
        UISearchBar.appearance().backgroundColor = UIColor(hex: themeInfo.searchBarBackgroundColor)
    }
    
    func getSelectedThemeInfo() -> ThemeInfo? {
        return infoItems?.filter({$0.themeName == themeInfo?.themeName}).first
    }
}
