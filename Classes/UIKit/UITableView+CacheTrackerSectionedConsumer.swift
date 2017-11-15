//
//  UITableView+CacheTrackerSectionedConsumer.swift
//
//  Created by Siarhei Ladzeika on 11/14/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import UIKit

extension UITableView: CacheTrackerSectionedConsumerDelegate {
    
    open func cacheTrackerSectionedConsumerBeginUpdates() {
        beginUpdates()
    }
    
    open func cacheTrackerSectionedConsumerDidUpdateSection(at sectionIndex: Int) {
        reloadSections(IndexSet(integer: sectionIndex), with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerDidRemoveSection(at sectionIndex: Int) {
        deleteSections(IndexSet(integer: sectionIndex), with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerDidInsertSection(at sectionIndex: Int) {
        insertSections(IndexSet(integer: sectionIndex), with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerDidUpdateItem(at indexPath: IndexPath) {
        reloadRows(at: [indexPath], with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerDidRemoveItem(at indexPath: IndexPath) {
        deleteRows(at: [indexPath], with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerDidInsertItem(at indexPath: IndexPath) {
        insertRows(at: [indexPath], with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerEndUpdates() {
        endUpdates()
    }

}

