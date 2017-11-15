//
//  CoreDataItem.swift
//  Demo
//
//  Created by Siarhei Ladzeika on 11/13/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import CoreData
import CacheTracker

@objc(CoreDataItem)
class CoreDataItem: NSManagedObject, CacheTrackerDatabaseModel {
    
    @NSManaged var name: String?
    @NSManaged var section: String? // section = [0] of name, for example: name='ABC' -> section = 'A'
    
    // MARK: - CacheTrackerDatabaseModel
    
    static func entityName() -> String {
        return NSStringFromClass(self)
    }
    
    func toPlainModel<P>() -> P? {
        return PlainItem(name: self.name!) as? P
    }
}
