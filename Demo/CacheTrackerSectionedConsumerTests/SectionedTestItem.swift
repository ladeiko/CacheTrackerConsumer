//
//  SectionedTestItem.swift
//  CacheTrackerSectionedConsumerTests
//
//  Created by Siarhei Ladzeika on 11/3/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//
import CoreData
import Foundation
import CacheTrackerConsumer
import CacheTracker

public class SectionedTestItem: CacheTrackerSectionedConsumerModel, CacheTrackerPlainModel {
    
    init(name: String) {
        self.name = name
    }
    
    init(model: Any) {
        self.name = (model as! TestModel).name!
    }
    
    var section: String {
        return self.name == "" ? "" : String(self.name.prefix(1))
    }
    
    let name: String
    
    public func sectionTitle() -> String {
        return section
    }
    
    @objc public var description: String {
        return name
    }

    class func from(model: Any) -> SectionedTestItem {
        return SectionedTestItem(model: model)
    }
    
    // MARK: - CacheTrackerPlainModel
    public required init() {
        self.name = ""
    }

}
