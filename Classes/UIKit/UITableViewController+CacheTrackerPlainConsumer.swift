//
//  UITableViewController+CacheTrackerPlainConsumer.swift
//
//  Created by Siarhei Ladzeika on 11/14/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import UIKit

extension UITableViewController: CacheTrackerPlainConsumerDelegate {
    
    open func cacheTrackerPlainConsumerBeginUpdates() {
        self.tableView.beginUpdates()
    }
    
    open func cacheTrackerPlainConsumerDidUpdateItem(at index: Int) {
        self.tableView.reloadRows(at: [IndexPath(row: index + cacheTrackerItemsOffset, section: cacheTrackerSectionOffset)], with: .fade)
    }
    
    open func cacheTrackerPlainConsumerDidRemoveItem(at index: Int) {
        self.tableView.deleteRows(at: [IndexPath(row: index + cacheTrackerItemsOffset, section: cacheTrackerSectionOffset)], with: .fade)
    }
    
    open func cacheTrackerPlainConsumerDidInsertItem(at index: Int) {
        self.tableView.insertRows(at: [IndexPath(row: index + cacheTrackerItemsOffset, section: cacheTrackerSectionOffset)], with: .fade)
    }
    
    open func cacheTrackerPlainConsumerEndUpdates() {
        self.tableView.endUpdates()
    }

}

