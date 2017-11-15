//
//  PlainItem.swift
//  Demo
//
//  Created by Siarhei Ladzeika on 11/13/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import Foundation
import CacheTracker
import CacheTrackerConsumer

class PlainItem: CacheTrackerPlainModel, CacheTrackerSectionedConsumerModel {
    
    let name: String
    let section: String
    
    init(name: String) {
        self.name = name
        self.section = String(name.prefix(1))
    }
    
    // MARK: - CacheTrackerPlainModel
    
    required init() {
        self.name = ""
        self.section = ""
    }
    
    // MARK: - CacheTrackerSectionedConsumerModel
    
    func sectionTitle() -> String {
        return self.section
    }

}
