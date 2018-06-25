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

public class RecurrentTestItem: TestItem, CacheTrackerPlainRecurrentConsumerItem {
    
    var mapCalled = false
    
    // MARK: CacheTrackerPlainRecurrentConsumerItem
    
    public func recurrentPlainConsumerItem(using oldValue: CacheTrackerPlainRecurrentConsumerItem) -> CacheTrackerPlainRecurrentConsumerItem {
        let oldValue = oldValue as! RecurrentTestItem
        mapCalled = true
        return RecurrentTestItem(name: self.name, section: oldValue.section)
    }
    
}
