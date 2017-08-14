//
//  Day+CoreDataProperties.swift
//  TimeManager
//
//  Created by Trong Nghia Hoang on 6/2/17.
//  Copyright © 2017 Trong Nghia Hoang. All rights reserved.
//

import Foundation
import CoreData


extension Day {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Day> {
        return NSFetchRequest<Day>(entityName: "Day")
    }

    @NSManaged public var day: NSDate?
    @NSManaged public var toActivity: NSSet?

}

// MARK: Generated accessors for toActivity
extension Day {

    @objc(addToActivityObject:)
    @NSManaged public func addToToActivity(_ value: Activity)

    @objc(removeToActivityObject:)
    @NSManaged public func removeFromToActivity(_ value: Activity)

    @objc(addToActivity:)
    @NSManaged public func addToToActivity(_ values: NSSet)

    @objc(removeToActivity:)
    @NSManaged public func removeFromToActivity(_ values: NSSet)

}
