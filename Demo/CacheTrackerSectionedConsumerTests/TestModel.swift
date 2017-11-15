//
//  TestModel.swift
//  CacheTrackerSectionedConsumerTests
//
//  Created by Siarhei Ladzeika on 11/4/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import Foundation
import CoreData

public protocol TestModelInitializable {
    associatedtype DB
    static func from(model: DB) -> AnyObject
}

@objc(TestModel)
public class TestModel: NSManagedObject, TestModelInitializable {
    
    @NSManaged var name: String?
    @NSManaged var section: String?
    
    public class func from(model: AnyObject) -> AnyObject {
        return SectionedTestItem(name: (model as! TestModel).name!)
    }
}
