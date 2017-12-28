//
//  UICollectionView+CacheTrackerConsumer.swift
//  CacheTracker
//
//  Created by Siarhei Ladzeika on 12/28/17.
//

import UIKit
import ObjectiveC.runtime

extension UICollectionView {
    
    private struct AssociatedKeys {
        static var offset = ""
        static var sectionOffset = ""
    }
    
    open var cacheTrackerItemsOffset: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.offset) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.offset, newValue as NSNumber, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open var cacheTrackerSectionOffset: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.sectionOffset) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.sectionOffset, newValue as NSNumber, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open func plainSection(_ section: Int) -> Int {
        return section - cacheTrackerSectionOffset
    }
    
    open func sectionedSection(_ section: Int) -> Int {
        return section - cacheTrackerSectionOffset
    }
    
    open func plainIndexPath(from globalIndexPath: IndexPath) -> IndexPath {
        return IndexPath(row: globalIndexPath.row - cacheTrackerItemsOffset, section: globalIndexPath.section - cacheTrackerSectionOffset)
    }
    
    open func sectionedIndexPath(from globalIndexPath: IndexPath) -> IndexPath {
        return IndexPath(row: globalIndexPath.row, section: globalIndexPath.section - cacheTrackerSectionOffset)
    }
    
    open func globalIndexPathPlain(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row + cacheTrackerItemsOffset, section: indexPath.section + cacheTrackerSectionOffset)
    }
    
    open func globalIndexPathFromSectioned(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)
    }
    
    open func globalSectionCount(_ sectionCount: Int) -> Int {
        return sectionCount + cacheTrackerSectionOffset
    }
    
    open func isPlainDataSection(_ section: Int) -> Bool {
        return section >= cacheTrackerSectionOffset
    }
    
    open func isSectionedDataSection(_ section: Int) -> Bool {
        return section >= cacheTrackerSectionOffset
    }
    
    open func isPlainDataIndexPath(_ indexPath: IndexPath) -> Bool {
        return isPlainDataSection(indexPath.section) && indexPath.row >= cacheTrackerItemsOffset
    }
    
    open func isSectionedDataIndexPath(_ indexPath: IndexPath) -> Bool {
        return isSectionedDataSection(indexPath.section)
    }
    
}

extension UICollectionViewController {
    
    open var cacheTrackerItemsOffset: Int {
        get {
            assert(isViewLoaded)
            return collectionView?.cacheTrackerItemsOffset ?? 0
        }
        set {
            assert(isViewLoaded)
            collectionView?.cacheTrackerItemsOffset = newValue
        }
    }
    
    open var cacheTrackerSectionOffset: Int {
        get {
            assert(isViewLoaded)
            return collectionView?.cacheTrackerSectionOffset ?? 0
        }
        set {
            assert(isViewLoaded)
            collectionView?.cacheTrackerSectionOffset = newValue
        }
    }
    
    open func plainSection(_ section: Int) -> Int {
        return section - cacheTrackerSectionOffset
    }
    
    open func sectionedSection(_ section: Int) -> Int {
        return section - cacheTrackerSectionOffset
    }
    
    open func plainIndexPath(from globalIndexPath: IndexPath) -> IndexPath {
        return IndexPath(row: globalIndexPath.row - cacheTrackerItemsOffset, section: globalIndexPath.section - cacheTrackerSectionOffset)
    }
    
    open func sectionedIndexPath(from globalIndexPath: IndexPath) -> IndexPath {
        return IndexPath(row: globalIndexPath.row, section: globalIndexPath.section - cacheTrackerSectionOffset)
    }
    
    open func globalIndexPathPlain(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row + cacheTrackerItemsOffset, section: indexPath.section + cacheTrackerSectionOffset)
    }
    
    open func globalIndexPathFromSectioned(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)
    }
    
    open func globalSectionCount(_ sectionCount: Int) -> Int {
        return sectionCount + cacheTrackerSectionOffset
    }
    
    open func isPlainDataSection(_ section: Int) -> Bool {
        return section >= cacheTrackerSectionOffset
    }
    
    open func isSectionedDataSection(_ section: Int) -> Bool {
        return section >= cacheTrackerSectionOffset
    }
    
    open func isPlainDataIndexPath(_ indexPath: IndexPath) -> Bool {
        return isPlainDataSection(indexPath.section) && indexPath.row >= cacheTrackerItemsOffset
    }
    
    open func isSectionedDataIndexPath(_ indexPath: IndexPath) -> Bool {
        return isSectionedDataSection(indexPath.section)
    }
}
