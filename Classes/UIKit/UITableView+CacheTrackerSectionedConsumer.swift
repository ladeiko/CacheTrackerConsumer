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
        reloadSections(IndexSet(integer: sectionIndex + cacheTrackerSectionOffset), with: cacheTrackerReloadAnimation)
    }
    
    open func cacheTrackerSectionedConsumerDidRemoveSection(at sectionIndex: Int) {
        deleteSections(IndexSet(integer: sectionIndex + cacheTrackerSectionOffset), with: cacheTrackerDeleteAnimation)
    }
    
    open func cacheTrackerSectionedConsumerDidInsertSection(at sectionIndex: Int) {
        insertSections(IndexSet(integer: sectionIndex + cacheTrackerSectionOffset), with: cacheTrackerInsertAnimation)
    }
    
    open func cacheTrackerSectionedConsumerDidUpdateItem(at indexPath: IndexPath) {
        
        let indexPath = IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)
        
        if let onReload = self.cacheTrackerOnReloadBlock, !onReload(indexPath) {
            return
        }

        if #available(iOS 15.0, *) {
            reconfigureRows(at: [indexPath])
        } else {
            reloadRows(at: [indexPath], with: cacheTrackerReloadAnimation)
        }
    }
    
    open func cacheTrackerSectionedConsumerDidRemoveItem(at indexPath: IndexPath) {
        deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)], with: cacheTrackerDeleteAnimation)
    }
    
    open func cacheTrackerSectionedConsumerDidInsertItem(at indexPath: IndexPath) {
        insertRows(at: [IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)], with: cacheTrackerInsertAnimation)
    }
    
    open func cacheTrackerSectionedConsumerEndUpdates() {
        let exception = CacheTrackerConsumer_tryBlock {
            self.endUpdates()
        }
        if exception != nil {
            CacheTrackerConsumer_tryBlock {
                self.reloadData()
            }
        }
    }

}

