//
//  Event+CoreDataProperties.swift
//  
//
//  Created by Ruggero Civitarese on 21/01/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event");
    }

    @NSManaged public var allday: Bool
    @NSManaged public var date: Date?
    @NSManaged public var every: Int32
    @NSManaged public var repeatition: Bool
    @NSManaged public var rolledDate: Date?
    @NSManaged public var title: String?

}
