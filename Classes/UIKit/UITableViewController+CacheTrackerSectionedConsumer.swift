//
//  UITableViewController+CacheTrackerSectionedConsumer.swift
//
//  Created by Siarhei Ladzeika on 11/14/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import UIKit

extension UITableViewController: CacheTrackerSectionedConsumerDelegate {
    
    open func cacheTrackerSectionedConsumerBeginUpdates() {
        self.tableView.beginUpdates()
    }
    
    open func cacheTrackerSectionedConsumerDidUpdateSection(at sectionIndex: Int) {
        self.tableView.reloadSections(IndexSet(integer: sectionIndex), with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerDidRemoveSection(at sectionIndex: Int) {
        self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerDidInsertSection(at sectionIndex: Int) {
        self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerDidUpdateItem(at indexPath: IndexPath) {
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerDidRemoveItem(at indexPath: IndexPath) {
        self.tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerDidInsertItem(at indexPath: IndexPath) {
        self.tableView.insertRows(at: [indexPath], with: .fade)
    }
    
    open func cacheTrackerSectionedConsumerEndUpdates() {
        self.tableView.endUpdates()
    }

}

