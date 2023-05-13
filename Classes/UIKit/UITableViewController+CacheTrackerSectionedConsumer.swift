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
        self.tableView.reloadSections(IndexSet(integer: sectionIndex + cacheTrackerSectionOffset),
                                      with: cacheTrackerReloadAnimation)
    }
    
    open func cacheTrackerSectionedConsumerDidRemoveSection(at sectionIndex: Int) {
        self.tableView.deleteSections(IndexSet(integer: sectionIndex + cacheTrackerSectionOffset),
                                      with: cacheTrackerDeleteAnimation)
    }
    
    open func cacheTrackerSectionedConsumerDidInsertSection(at sectionIndex: Int) {
        self.tableView.insertSections(IndexSet(integer: sectionIndex + cacheTrackerSectionOffset),
                                      with: cacheTrackerInsertAnimation)
    }
    
    open func cacheTrackerSectionedConsumerDidUpdateItem(at indexPath: IndexPath) {
        
        let indexPath = IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)
        
        if let onReload = self.tableView.cacheTrackerOnReloadBlock, !onReload(indexPath) {
            return
        }

        if #available(iOS 15.0, *) {
            self.tableView.reconfigureRows(at: [indexPath])
        } else {
            self.tableView.reloadRows(at: [indexPath], with: cacheTrackerReloadAnimation)
        }
    }
    
    open func cacheTrackerSectionedConsumerDidRemoveItem(at indexPath: IndexPath) {
        self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)],
                                  with: cacheTrackerDeleteAnimation)
    }
    
    open func cacheTrackerSectionedConsumerDidInsertItem(at indexPath: IndexPath) {
        self.tableView.insertRows(at: [IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)],
                                  with: cacheTrackerInsertAnimation)
    }
    
    open func cacheTrackerSectionedConsumerEndUpdates() {
        self.tableView.endUpdates()
    }

}

