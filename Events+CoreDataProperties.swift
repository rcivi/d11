//
//  Events+CoreDataProperties.swift
//  
//
//  Created by Ruggero Civitarese on 21/01/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Events {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Events> {
        return NSFetchRequest<Events>(entityName: "Events");
    }

    @NSManaged public var allday: Bool
    @NSManaged public var date: NSDate?
    @NSManaged public var every: Int16
    @NSManaged public var repeatition: Bool
    @NSManaged public var rolledDate: NSDate?
    @NSManaged public var title: String?

}
