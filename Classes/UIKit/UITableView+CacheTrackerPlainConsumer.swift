//
//  UITableView+CacheTrackerPlainConsumer.swift
//
//  Created by Siarhei Ladzeika on 11/14/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import UIKit

extension UITableView: CacheTrackerPlainConsumerDelegate {
    
    open func cacheTrackerPlainConsumerBeginUpdates() {
        beginUpdates()
    }
    
    open func cacheTrackerPlainConsumerDidUpdateItem(at index: Int) {
        reloadRows(at: [IndexPath(row: index + cacheTrackerItemsOffset, section: cacheTrackerSectionOffset)], with: .fade)
    }
    
    open func cacheTrackerPlainConsumerDidRemoveItem(at index: Int) {
        deleteRows(at: [IndexPath(row: index + cacheTrackerItemsOffset, section: cacheTrackerSectionOffset)], with: .fade)
    }
    
    open func cacheTrackerPlainConsumerDidInsertItem(at index: Int) {
        insertRows(at: [IndexPath(row: index + cacheTrackerItemsOffset, section: cacheTrackerSectionOffset)], with: .fade)
    }
    
    open func cacheTrackerPlainConsumerEndUpdates() {
        endUpdates()
    }

}

