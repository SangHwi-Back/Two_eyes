//
//  ThemeManager.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/08/19.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
// https://medium.com/@abhimuralidharan/maintaining-a-colour-theme-manager-on-ios-swift-178b8a6a92
//

import UIKit
import CoreData

struct ThemeInfo: Codable {
    var rootBackgroundViewColor: String?
    var navigationBackgroundColor: String?
    var buttonBackgroundColor: String?
    var buttonTintColor: String?
    var buttonTextColor: String?
    var labelTintColor: String?
    var textFieldTintColor: String?
    var bodyTextColor: String?
    var collectionViewBackgroundColor: String?
    var searchBarBackgroundColor: String?
    var contents: String?
    var themeName: String
}

class ThemeManager {
    
    func getThemeBackgroundColor() -> UIColor {
        return themeBackgroundColor == nil ? UIColor.systemBackground : themeBackgroundColor!
    }
    
    func getNavtabBackgroundColor() -> UIColor {
        return navTabBackgroundColor == nil ? UIColor.systemBackground : navTabBackgroundColor!
    }
    
    func getBodyTextColor() -> UIColor {
        return bodyTextColor == nil ? UIColor.black : bodyTextColor!
    }
    
    private let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    lazy private var context = appDelegate?.persistentContainer.viewContext
    
    private let userDefaultsKey = "MainTheme"
    
    lazy private(set) var selectedThemeKey = UserDefaults.standard.value(forKey: userDefaultsKey) as? String ?? "Default"
    private(set) var storedThemes : [ApplicationTheme]?
    private var themeBackgroundColor: UIColor?
    private var navTabBackgroundColor: UIColor?
    private var bodyTextColor: UIColor?
    
    private(set) var navigationBarApperance: UINavigationBarAppearance?
    private(set) var navigationBarButtonItemApperance: UIBarButtonItemAppearance?
    
    func setDefaultTheme() {
        guard let context = context else {
            return
        }
        
        let entity = NSEntityDescription.entity(forEntityName: Constants.themeEntityName, in: context)
        
        if let entity = entity {
            for themeItem in Constants.applicationDefaultThemes {
                let theme = ApplicationTheme(entity: entity, insertInto: context)
                for themeItemKey in themeItem.value.keys {
                    theme.setValue(themeItem.value[themeItemKey]!, forKey: themeItemKey)
                }
            }
        }
        
        do {
            try context.save()
            self.getThemes()
        } catch {
            print("error in COMMITing save default themes")
        }
    }
    
    func applyTheme() {
        // UserDefaults.standard.synchronize() //check userDefaults save the data successfully(Bool)
        
        guard !(self.storedThemes?.isEmpty ?? true), let storedThemes = self.storedThemes else {
            setDefaultTheme()
            print("escape in 'let storedThemes = storedThemes'.")
            return
        }
        
        guard self.selectedThemeKey != "Default" else {
            applyDefaultTheme()
            print("set default theme and return")
            return
        }
        
        guard let theme = storedThemes.filter({$0.id == self.selectedThemeKey}).first else {
            print("chosen theme not found")
            return
        }
        
        self.themeBackgroundColor = theme.backGround_Color.toUIColor
        self.navTabBackgroundColor = theme.nav_tabBar_Color.toUIColor
        self.bodyTextColor = theme.bodyText_Color.toUIColor
        
        UIButton.appearance().backgroundColor = theme.button_Color.toUIColor
        UIButton.appearance().tintColor = theme.buttonText_Color.toUIColor
        UILabel.appearance().tintColor = theme.bodyText_Color.toUIColor
        UITextField.appearance().tintColor = theme.bodyText_Color.toUIColor
        UICollectionView.appearance().backgroundColor = theme.backGround_Color.toUIColor
        UISearchBar.appearance().backgroundColor = theme.nav_tabBar_Color.toUIColor
        
        print("Completed theme apply", theme)
    }
    
    func applyDefaultTheme() {
        
        self.themeBackgroundColor = nil
        self.navTabBackgroundColor = nil
        self.bodyTextColor = nil
        
        UIButton.appearance().backgroundColor = nil
        UIButton.appearance().tintColor = UIColor(named: "black")
        UILabel.appearance().tintColor = nil
        UITextField.appearance().tintColor = nil
        UICollectionView.appearance().backgroundColor = nil
        UISearchBar.appearance().tintColor = UIColor(named: "white")
    }
    
    func setSelectedThemeKey(_ key: String) {
        self.selectedThemeKey = key
    }
    
    @discardableResult
    func getThemes() -> Bool {
        if let context = context {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.themeEntityName)
            do {
                if let fetchResults: [ApplicationTheme] = try? context.fetch(fetchRequest) as? [ApplicationTheme] {
                    self.storedThemes = fetchResults
                    return true
                } else {
                    return false
                }
            }
        } else {
            return false
        }
    }
    
    func deleteAllData() {
        do {
            if let fetchResults = try context?.fetch(NSFetchRequest(entityName: Constants.themeEntityName)) as? [ApplicationTheme] {
                for result in fetchResults {
                    self.context?.delete(result)
                }
                
                do {
                    try context?.save()
                } catch {
                    print("!!!CORE DATA!!! error in DELETE all COMMIT")
                }
            }
        } catch {
            print("!!!CORE DATA!!! error in DELETE")
        }
    }
}
