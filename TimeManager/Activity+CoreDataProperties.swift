//
//  Activity+CoreDataProperties.swift
//  TimeManager
//
//  Created by Trong Nghia Hoang on 6/2/17.
//  Copyright © 2017 Trong Nghia Hoang. All rights reserved.
//

import Foundation
import CoreData


extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var activityDescription: String?
    @NSManaged public var color: String?
    @NSManaged public var day: NSDate?
    @NSManaged public var from: NSDate?
    @NSManaged public var info: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var thumbURL: String?
    @NSManaged public var title: String?
    @NSManaged public var to: NSDate?
    @NSManaged public var type: String?
    @NSManaged public var toDay: Day?

}
