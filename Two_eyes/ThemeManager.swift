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

extension String {
    var toUIColor: UIColor {
        let rgb = Array(self.split(separator: "."))
        return UIColor(displayP3Red: CGFloat(Int(rgb[0])!) / 255, green: CGFloat(Int(rgb[1])!) / 255, blue: CGFloat(Int(rgb[2])!) / 255, alpha: 1)
    }
}

struct Theme {
    var bodyText_Color: String
    var buttonText_Color: String
    var button_Color: String
    var nav_tabBar_Color: String
    var themeName: String
}

class ThemeManager {
    
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    let userDefaultsKey = "MainTheme"
    
    lazy var selectedThemeKey = UserDefaults.standard.value(forKey: userDefaultsKey) as? String ?? "Default"
    var storedThemes : [ApplicationTheme]?
    
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
        } catch {
            print("error in COMMITing save default themes")
        }
    }
    
    func applyTheme() {
        // UserDefaults.standard.synchronize() //check userDefaults save the data successfully(Bool)
        guard let storedThemes = self.storedThemes else {
            setDefaultTheme()
            print("escape in 'let storedThemes = storedThemes'.")
            return
        }
        
        guard self.selectedThemeKey != "Default", let theme = storedThemes.filter({$0.id == self.selectedThemeKey}).first else {
            print("escape in 'selectedThemeKey != \"Default\", let theme = storedThemes.filter({$0.id == selectedThemeKey}).first'.")
            return
        }
        
        let sharedApplication = UIApplication.shared // singleton app instance
        sharedApplication.delegate?.window??.tintColor = theme.backGround_Color.toUIColor
        
        UINavigationBar.appearance().backgroundColor = theme.nav_tabBar_Color.toUIColor
        UITabBar.appearance().backgroundColor = theme.nav_tabBar_Color.toUIColor
        UIButton.appearance().backgroundColor = theme.button_Color.toUIColor
        UIButton.appearance().tintColor = theme.buttonText_Color.toUIColor
        UILabel.appearance().tintColor = theme.bodyText_Color.toUIColor
        UITextField.appearance().tintColor = theme.bodyText_Color.toUIColor
        UISearchBar.appearance().tintColor = theme.buttonText_Color.toUIColor
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
