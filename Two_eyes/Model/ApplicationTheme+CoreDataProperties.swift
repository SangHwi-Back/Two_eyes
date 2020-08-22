//
//  ApplicationTheme+CoreDataProperties.swift
//  
//
//  Created by 백상휘 on 2020/08/21.
//
//

import Foundation
import CoreData


extension ApplicationTheme {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ApplicationTheme> {
        return NSFetchRequest<ApplicationTheme>(entityName: "ApplicationTheme")
    }

    @NSManaged public var backGround_Color: String
    @NSManaged public var bodyText_Color: String
    @NSManaged public var button_Color: String
    @NSManaged public var buttonText_Color: String
    @NSManaged public var nav_tabBar_Color: String
    @NSManaged public var id: String

}
