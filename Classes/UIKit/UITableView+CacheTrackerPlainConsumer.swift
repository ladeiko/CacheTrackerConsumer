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
        
        let indexPath = IndexPath(row: index + cacheTrackerItemsOffset, section: cacheTrackerSectionOffset)
        
        if let onReload = self.cacheTrackerOnReloadBlock, !onReload(indexPath) {
            return
        }

        if #available(iOS 15.0, *) {
            reconfigureRows(at: [indexPath])
        } else {
            reloadRows(at: [indexPath], with: cacheTrackerReloadAnimation)
        }
    }
    
    open func cacheTrackerPlainConsumerDidRemoveItem(at index: Int) {
        deleteRows(at: [IndexPath(row: index + cacheTrackerItemsOffset, section: cacheTrackerSectionOffset)], with: cacheTrackerDeleteAnimation)
    }
    
    open func cacheTrackerPlainConsumerDidInsertItem(at index: Int) {
        insertRows(at: [IndexPath(row: index + cacheTrackerItemsOffset, section: cacheTrackerSectionOffset)], with: cacheTrackerInsertAnimation)
    }
    
    open func cacheTrackerPlainConsumerEndUpdates() {
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

