//
//  Event+CoreDataProperties.swift
//  
//
//  Created by Ruggero Civitarese on 13/02/17.
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
    @NSManaged public var date: NSDate?
    @NSManaged public var endRepeatQuantity: Int32
    @NSManaged public var endRepeatType: Int32
    @NSManaged public var every: Int32
    @NSManaged public var repeatition: Bool
    @NSManaged public var repeatQuantity: Int32
    @NSManaged public var repeatType: Int32
    @NSManaged public var rolledDate: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var notifyType: Int32
    @NSManaged public var notifyQuantity: Int32
    @NSManaged public var notifyMode: Int32

}
