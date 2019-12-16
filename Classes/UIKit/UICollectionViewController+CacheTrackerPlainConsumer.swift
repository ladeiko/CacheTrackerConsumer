//
//  UICollectionViewController+CacheTrackerPlainConsumer.swift
//
//  Created by Siarhei Ladzeika on 11/14/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

extension UICollectionViewController: CacheTrackerPlainConsumerDelegate {

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
    
    open func cacheTrackerPlainConsumerBatchUpdates(_ applyChangesBlock: @escaping CacheTrackerPlainConsumerDelegateEndUpdatesBlock) {
        self.collectionView?.ctc_performBatchUpdates({
            applyChangesBlock()
        }, completion: nil)
    }
    
    open func cacheTrackerPlainConsumerBeginUpdates() {
        plainUpdates = [CacheTrackerPlainConsumerOperation]()
    }
    
    open func cacheTrackerPlainConsumerDidUpdateItem(at index: Int) {
        plainUpdates!.append(CacheTrackerPlainConsumerOperation(type: .itemUpdate, index: index + cacheTrackerItemsOffset))
    }
    
    open func cacheTrackerPlainConsumerDidRemoveItem(at index: Int) {
        plainUpdates!.append(CacheTrackerPlainConsumerOperation(type: .itemDelete, index: index + cacheTrackerItemsOffset))
    }
    
    open func cacheTrackerPlainConsumerDidInsertItem(at index: Int) {
        plainUpdates!.append(CacheTrackerPlainConsumerOperation(type: .itemInsert, index: index + cacheTrackerItemsOffset))
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
        
        for update in updates {
            switch update.type {
            case .itemInsert:
                self.collectionView!.insertItems(at: [IndexPath(row: update.index, section: self.cacheTrackerSectionOffset)])
            case .itemDelete:
                self.collectionView!.deleteItems(at: [IndexPath(row: update.index, section: self.cacheTrackerSectionOffset)])
            case .itemUpdate:
                
                let indexPath = IndexPath(row: update.index, section: self.cacheTrackerSectionOffset)
                
                if let onReload = self.collectionView!.cacheTrackerOnReloadBlock, !onReload(indexPath) {
                    break
                }
                
                self.collectionView!.reloadItems(at: [indexPath])
            }
        }
    }

}

