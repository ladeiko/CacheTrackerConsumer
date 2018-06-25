//
//  TestItem.swift
//  CacheTrackerSectionedConsumerTests
//
//  Created by Siarhei Ladzeika on 6/25/18.
//  Copyright © 2018 Siarhei Ladzeika. All rights reserved.
//

import Foundation
import CacheTrackerConsumer
import CacheTracker

public class TestItem: CacheTrackerPlainModel {
    
    let name: String
    let section: String
    
    init(name: String) {
        self.name = name
        self.section = String(name.prefix(1))
    }
    
    init(name: String, section: String) {
        self.name = name
        self.section = section
    }
    
    // MARK: - CacheTrackerPlainModel
    
    required public init() {
        self.name = ""
        self.section = ""
    }
    
}
