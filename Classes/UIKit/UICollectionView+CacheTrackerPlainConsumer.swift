//
//  UICollectionView+CacheTrackerPlainConsumer.swift
//
//  Created by Siarhei Ladzeika on 11/14/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

extension UICollectionView: CacheTrackerPlainConsumerDelegate {

    private enum CacheTrackerPlainConsumerOperationType {
        case itemInsert
        case itemDelete
        case itemUpdate
    }
    
    private struct CacheTrackerPlainConsumerOperation {
        var type: CacheTrackerPlainConsumerOperationType
        var index: Int
    }
    
    private struct AssociatedKeys {
        static var plainUpdates = ""
    }
    
    private var plainUpdates: [CacheTrackerPlainConsumerOperation]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.plainUpdates) as? [CacheTrackerPlainConsumerOperation]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.plainUpdates, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open func cacheTrackerPlainConsumerBeginUpdates() {
        plainUpdates = [CacheTrackerPlainConsumerOperation]()
    }
    
    open func cacheTrackerPlainConsumerDidUpdateItem(at index: Int) {
        plainUpdates!.append(CacheTrackerPlainConsumerOperation(type: .itemUpdate, index: index))
    }
    
    open func cacheTrackerPlainConsumerDidRemoveItem(at index: Int) {
        plainUpdates!.append(CacheTrackerPlainConsumerOperation(type: .itemDelete, index: index))
    }
    
    open func cacheTrackerPlainConsumerDidInsertItem(at index: Int) {
        plainUpdates!.append(CacheTrackerPlainConsumerOperation(type: .itemInsert, index: index))
    }
    
    open func cacheTrackerPlainConsumerEndUpdates() {
        defer {
            plainUpdates = nil
        }
        
        guard let updates = plainUpdates else {
            return
        }
        
        guard !updates.isEmpty else {
            return
        }
        
        performBatchUpdates({
            for update in updates {
                switch update.type {
                case .itemInsert:
                    self.insertItems(at: [IndexPath(row:update.index, section: 0)])
                case .itemDelete:
                    self.deleteItems(at: [IndexPath(row:update.index, section: 0)])
                case .itemUpdate:
                    self.reloadItems(at: [IndexPath(row:update.index, section: 0)])
                }
            }
        }, completion: nil)
    }

}

