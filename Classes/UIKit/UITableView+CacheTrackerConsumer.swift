//
//  UITableView+CacheTrackerConsumer.swift
//  CacheTracker
//
//  Created by Siarhei Ladzeika on 12/28/17.
//

import UIKit
import ObjectiveC.runtime

extension UITableView {
    
    private struct AssociatedKeys {
        static var reloadAnimation = ""
        static var insertAnimation = ""
        static var deleteAnimation = ""
        static var onReload = ""
        static var offset = ""
        static var sectionOffset = ""
    }

    public var cacheTrackerReloadAnimation: RowAnimation {
        get {
            return RowAnimation(rawValue: (objc_getAssociatedObject(self, &AssociatedKeys.reloadAnimation) as? Int) ?? RowAnimation.fade.rawValue) ?? .fade
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.reloadAnimation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var cacheTrackerInsertAnimation: RowAnimation {
        get {
            return RowAnimation(rawValue: (objc_getAssociatedObject(self, &AssociatedKeys.insertAnimation) as? Int) ?? RowAnimation.fade.rawValue) ?? .fade
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.insertAnimation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var cacheTrackerDeleteAnimation: RowAnimation {
        get {
            return RowAnimation(rawValue: (objc_getAssociatedObject(self, &AssociatedKeys.deleteAnimation) as? Int) ?? RowAnimation.fade.rawValue) ?? .fade
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.deleteAnimation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var cacheTrackerOnReloadBlock: ((_ indexPath: IndexPath) -> Bool)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onReload) as? ((_ indexPath: IndexPath) -> Bool)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onReload, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var cacheTrackerItemsOffset: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.offset) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.offset, newValue as NSNumber, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var cacheTrackerSectionOffset: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.sectionOffset) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.sectionOffset, newValue as NSNumber, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func plainSection(_ section: Int) -> Int {
        return section - cacheTrackerSectionOffset
    }
    
    public func sectionedSection(_ section: Int) -> Int {
        return section - cacheTrackerSectionOffset
    }
    
    public func plainIndexPath(from globalIndexPath: IndexPath) -> IndexPath {
        return IndexPath(row: globalIndexPath.row - cacheTrackerItemsOffset, section: globalIndexPath.section - cacheTrackerSectionOffset)
    }
    
    public func sectionedIndexPath(from globalIndexPath: IndexPath) -> IndexPath {
        return IndexPath(row: globalIndexPath.row, section: globalIndexPath.section - cacheTrackerSectionOffset)
    }
    
    public func globalIndexPathPlain(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row + cacheTrackerItemsOffset, section: indexPath.section + cacheTrackerSectionOffset)
    }
    
    public func globalIndexPathFromSectioned(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)
    }
    
    public func globalSectionCount(_ sectionCount: Int) -> Int {
        return sectionCount + cacheTrackerSectionOffset
    }
    
    public func isPlainDataSection(_ section: Int) -> Bool {
        return section >= cacheTrackerSectionOffset
    }
    
    public func isSectionedDataSection(_ section: Int) -> Bool {
        return section >= cacheTrackerSectionOffset
    }
    
    public func isPlainDataIndexPath(_ indexPath: IndexPath) -> Bool {
        return isPlainDataSection(indexPath.section) && indexPath.row >= cacheTrackerItemsOffset
    }
    
    public func isSectionedDataIndexPath(_ indexPath: IndexPath) -> Bool {
        return isSectionedDataSection(indexPath.section)
    }
}

extension UITableViewController {

    public var cacheTrackerReloadAnimation: UITableView.RowAnimation {
        get {
            assert(isViewLoaded)
            return tableView?.cacheTrackerReloadAnimation ?? .fade
        }
        set {
            assert(isViewLoaded)
            tableView?.cacheTrackerReloadAnimation = newValue
        }
    }

    public var cacheTrackerInsertAnimation: UITableView.RowAnimation {
        get {
            assert(isViewLoaded)
            return tableView?.cacheTrackerInsertAnimation ?? .fade
        }
        set {
            assert(isViewLoaded)
            tableView?.cacheTrackerInsertAnimation = newValue
        }
    }

    public var cacheTrackerDeleteAnimation: UITableView.RowAnimation {
        get {
            assert(isViewLoaded)
            return tableView?.cacheTrackerDeleteAnimation ?? .fade
        }
        set {
            assert(isViewLoaded)
            tableView?.cacheTrackerDeleteAnimation = newValue
        }
    }
    
    public var cacheTrackerItemsOffset: Int {
        get {
            assert(isViewLoaded)
            return tableView?.cacheTrackerItemsOffset ?? 0
        }
        set {
            assert(isViewLoaded)
            tableView?.cacheTrackerItemsOffset = newValue
        }
    }
    
    public var cacheTrackerSectionOffset: Int {
        get {
            assert(isViewLoaded)
            return tableView?.cacheTrackerSectionOffset ?? 0
        }
        set {
            assert(isViewLoaded)
            tableView?.cacheTrackerSectionOffset = newValue
        }
    }
    
    public func plainSection(_ section: Int) -> Int {
        return section - cacheTrackerSectionOffset
    }
    
    public func sectionedSection(_ section: Int) -> Int {
        return section - cacheTrackerSectionOffset
    }
    
    public func plainIndexPath(from globalIndexPath: IndexPath) -> IndexPath {
        return IndexPath(row: globalIndexPath.row - cacheTrackerItemsOffset, section: globalIndexPath.section - cacheTrackerSectionOffset)
    }
    
    public func sectionedIndexPath(from globalIndexPath: IndexPath) -> IndexPath {
        return IndexPath(row: globalIndexPath.row, section: globalIndexPath.section - cacheTrackerSectionOffset)
    }
    
    public func globalIndexPathPlain(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row + cacheTrackerItemsOffset, section: indexPath.section + cacheTrackerSectionOffset)
    }
    
    public func globalIndexPathFromSectioned(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row, section: indexPath.section + cacheTrackerSectionOffset)
    }
    
    public func globalSectionCount(_ sectionCount: Int) -> Int {
        return sectionCount + cacheTrackerSectionOffset
    }
    
    public func isPlainDataSection(_ section: Int) -> Bool {
        return section >= cacheTrackerSectionOffset
    }
    
    public func isSectionedDataSection(_ section: Int) -> Bool {
        return section >= cacheTrackerSectionOffset
    }
    
    public func isPlainDataIndexPath(_ indexPath: IndexPath) -> Bool {
        return isPlainDataSection(indexPath.section) && indexPath.row >= cacheTrackerItemsOffset
    }
    
    public func isSectionedDataIndexPath(_ indexPath: IndexPath) -> Bool {
        return isSectionedDataSection(indexPath.section)
    }
}
