//
//  UICollectionViewController+CacheTrackerSectionedConsumer.swift
//
//  Created by Siarhei Ladzeika on 11/14/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

extension UICollectionViewController: CacheTrackerSectionedConsumerDelegate {

    private enum CacheTrackerSectionedConsumerOperationType {
        case itemInsert
        case itemDelete
        case itemUpdate
        case sectionInsert
        case sectionDelete
        case sectionUpdate
    }
    
    private struct CacheTrackerSectionedConsumerOperation {
        var type: CacheTrackerSectionedConsumerOperationType
        var sectionIndex: Int?
        var itemIndex: IndexPath?
    }
    
    private struct AssociatedKeys {
        static var sectionedUpdates = ""
    }
    
    private var sectionedUpdates: [CacheTrackerSectionedConsumerOperation]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.sectionedUpdates) as? [CacheTrackerSectionedConsumerOperation]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.sectionedUpdates, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open func cacheTrackerSectionedConsumerBatchUpdates(_ applyChangesBlock: @escaping CacheTrackerSectionedConsumerDelegateEndUpdatesBlock) {
        self.collectionView?.ctc_performBatchUpdates({
            applyChangesBlock()
        }, completion: nil)
    }
    
    open func cacheTrackerSectionedConsumerBeginUpdates() {
        sectionedUpdates = [CacheTrackerSectionedConsumerOperation]()
    }
    
    open func cacheTrackerSectionedConsumerDidUpdateSection(at sectionIndex: Int) {
        sectionedUpdates!.append(CacheTrackerSectionedConsumerOperation(type: .sectionUpdate, sectionIndex: sectionIndex + cacheTrackerSectionOffset, itemIndex: nil))
    }
    
    open func cacheTrackerSectionedConsumerDidRemoveSection(at sectionIndex: Int) {
        sectionedUpdates!.append(CacheTrackerSectionedConsumerOperation(type: .sectionDelete, sectionIndex: sectionIndex + cacheTrackerSectionOffset, itemIndex: nil))
    }
    
    open func cacheTrackerSectionedConsumerDidInsertSection(at sectionIndex: Int) {
        sectionedUpdates!.append(CacheTrackerSectionedConsumerOperation(type: .sectionInsert, sectionIndex: sectionIndex + cacheTrackerSectionOffset, itemIndex: nil))
    }
    
    open func cacheTrackerSectionedConsumerDidUpdateItem(at indexPath: IndexPath) {
        sectionedUpdates!.append(CacheTrackerSectionedConsumerOperation(type: .itemUpdate, sectionIndex: nil, itemIndex: IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)))
    }
    
    open func cacheTrackerSectionedConsumerDidRemoveItem(at indexPath: IndexPath) {
        sectionedUpdates!.append(CacheTrackerSectionedConsumerOperation(type: .itemDelete, sectionIndex: nil, itemIndex: IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)))
    }
    
    open func cacheTrackerSectionedConsumerDidInsertItem(at indexPath: IndexPath) {
        sectionedUpdates!.append(CacheTrackerSectionedConsumerOperation(type: .itemInsert, sectionIndex: nil, itemIndex: IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)))
    }
    
    open func cacheTrackerSectionedConsumerEndUpdates() {
        defer {
            sectionedUpdates = nil
        }
        
        guard let updates = sectionedUpdates else {
            return
        }
        
        guard !updates.isEmpty else {
            return
        }
        
        for update in updates {
            switch update.type {
            case .sectionInsert:
                self.collectionView!.insertSections(IndexSet(integer: update.sectionIndex!))
            case .sectionDelete:
                self.collectionView!.deleteSections(IndexSet(integer: update.sectionIndex!))
            case .sectionUpdate:
                self.collectionView!.reloadSections(IndexSet(integer: update.sectionIndex!))
            case .itemInsert:
                self.collectionView!.insertItems(at: [update.itemIndex!])
            case .itemDelete:
                self.collectionView!.deleteItems(at: [update.itemIndex!])
            case .itemUpdate:
                
                let indexPath = update.itemIndex!
                
                if let onReload = self.collectionView!.cacheTrackerOnReloadBlock, !onReload(indexPath) {
                    break
                }
                
                self.collectionView!.reloadItems(at: [indexPath])
            }
        }
    }

}

