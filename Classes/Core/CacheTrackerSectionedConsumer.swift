//
//  CacheTrackerSectionedConsumer.swift
//
//  Created by Siarhei Ladzeika on 11/3/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import Foundation
import CacheTracker

public protocol CacheTrackerSectionedConsumerModel {
    func sectionTitle() -> String
}

@objc open class CacheTrackerSectionedConsumerChanges: NSObject {
    
    open let updatedRows: [IndexPath]!
    open let reloadedSections: [Int]!
    open let deletedSections: [Int]!
    open let insertedSections: [Int]!
    open let deletedRows: [IndexPath]!
    open let insertedRows: [IndexPath]!
    
    init(updatedRows: [IndexPath], reloadedSections: [Int], deletedSections: [Int], insertedSections: [Int], deletedRows: [IndexPath], insertedRows: [IndexPath]) {
        self.updatedRows = updatedRows
        self.reloadedSections = reloadedSections
        self.deletedSections = deletedSections
        self.insertedSections = insertedSections
        self.deletedRows = deletedRows
        self.insertedRows = insertedRows
    }
}

// Should be called inside performBatchUpdates of UICollectionView
public typealias CacheTrackerSectionedConsumerDelegateEndUpdatesBlock = () -> Void

@objc public protocol CacheTrackerSectionedConsumerDelegate {
    
    // Added to conform of behavior described in Apple docs:
    //
    //  https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/CollectionViewPGforIOS/CreatingCellsandViews/CreatingCellsandViews.html#//apple_ref/doc/uid/TP40012334-CH7-SW1
    //
    //
    // If implemented, then it is called but real updates to consumer are applied when 'applyChangesBlock' is called.
    //
    //  Execution flow:
    //      cacheTrackerPlainConsumerBatchUpdates: { // applyChangesBlock
    //
    //        cacheTrackerSectionedConsumerBeginUpdates
    //        cacheTrackerSectionedConsumerDidUpdateItem / cacheTrackerSectionedConsumerDidRemoveItem / cacheTrackerSectionedConsumerDidInsertItem, etc...
    //        cacheTrackerSectionedConsumerEndUpdates
    //
    //      }
    //
    // NOTE: Should be used when using UICollectionView:
    //
    //  func cacheTrackerSectionedConsumerBatchUpdates(_ block: CacheTrackerSectionedConsumerDelegateEndUpdatesBlock) {
    //      self.collectionView.performBatchUpdates({
    //          applyChangesBlock() // All changes will be applied to consumer and propagated to UICollectionView.
    //                              // See execution flow described before.
    //      }, completion: nil)
    //  }
    //
    //  See Demo project for examples.
    //
    
    @objc
    optional func cacheTrackerSectionedConsumerBatchUpdates(_ applyChangesBlock: @escaping CacheTrackerSectionedConsumerDelegateEndUpdatesBlock)
    
    func cacheTrackerSectionedConsumerBeginUpdates()
    func cacheTrackerSectionedConsumerDidUpdateSection(at sectionIndex: Int)
    func cacheTrackerSectionedConsumerDidRemoveSection(at sectionIndex: Int)
    func cacheTrackerSectionedConsumerDidInsertSection(at sectionIndex: Int)
    func cacheTrackerSectionedConsumerDidUpdateItem(at indexPath: IndexPath)
    func cacheTrackerSectionedConsumerDidRemoveItem(at indexPath: IndexPath)
    func cacheTrackerSectionedConsumerDidInsertItem(at indexPath: IndexPath)
    func cacheTrackerSectionedConsumerEndUpdates()
}

open class CacheTrackerSectionedConsumer<T: CacheTrackerSectionedConsumerModel & CacheTrackerPlainModel>: NSObject {
    
    private class Section {
        
        var indexBeforeUpdate: Int?
        var sectionTitleBeforeUpdate: String?
        
        var count: Int {
            return end - start
        }
        
        var start: Int = 0
        var end: Int = 0
        
        func isEmpty() -> Bool {
            return start == end
        }
    }
    
    private class IndexOperation {
        let index: Int
        
        init(_ index: Int) {
            self.index = index
        }
        
        class func comparator(_ reversed: Bool = false) -> (IndexOperation, IndexOperation) -> Bool {
            if reversed {
                return { (t1: IndexOperation, t2: IndexOperation) -> Bool in
                    return t1.index >= t2.index
                }
            }
            else {
                return { (t1: IndexOperation, t2: IndexOperation) -> Bool in
                    return t1.index <= t2.index
                }
            }
        }
        
    }
    
    private class ItemOperation: IndexOperation {
        let item: T
        init(_ item: T, at index: Int) {
            self.item = item
            super.init(index)
        }
    }
    
    open weak var delegate: CacheTrackerSectionedConsumerDelegate?
    
    private var _adds: [ItemOperation] = [ItemOperation]()
    private var _deletions: [IndexOperation] = [IndexOperation]()
    private var _updates: [ItemOperation] = [ItemOperation]()
    private var _trackChanges = false
    private var _items: [T] = [T]()
    private var _sections: [Section] = [Section]()
    private var _updatedSections: [Int]!
    private var _removedSections: [Int]!
    private var _insertedSections: [Int]!
    private var _updatedItems: [IndexPath]!
    private var _removedItems: [IndexPath]!
    private var _insertedItems: [IndexPath]!
    
    open func sectionsCount() -> Int {
        return _sections.count
    }
    
    open func numberOfItems(at sectionIndex: Int) -> Int {
        return _sections[sectionIndex].count
    }
    
    open func object(at indexPath: IndexPath) -> T {
        let section = _sections[indexPath.section]
        return _items[section.start + indexPath.row]
    }
    
    private func _sectionIndex(for linearItemIndex: Int) -> Int {
        for (i, s) in _sections.enumerated() {
            if s.start <= linearItemIndex && linearItemIndex < s.end {
                return i
            }
        }
        assertionFailure()
        return 0
    }
    
    private func _section(for linearItemIndex: Int) -> Section {
        return _sections[_sectionIndex(for: linearItemIndex)]
    }
    
    open func reset<P>(with transactions: [CacheTransaction<P>] = [CacheTransaction<P>](), notifyingDelegate: Bool = false) {
        
        precondition(!_trackChanges)
        _sections.removeAll()
        _items.removeAll()
        
        let currentDelegate = delegate
        
        if !notifyingDelegate {
            delegate = nil
        }
        
        willChange()
        consume(transactions: transactions)
        didChange()
        
        delegate = currentDelegate
    }
    
    open func add(_ item: T, at linearItemIndex: Int) {
        precondition(_trackChanges)
        _adds.append(ItemOperation(item, at: linearItemIndex))
    }
    
    private func _add(_ item: T, at linearItemIndex: Int) {
        
        precondition(_trackChanges)
        precondition(linearItemIndex >= 0 && linearItemIndex <= _items.count)
        
        if _items.count == 0 {
            _items.append(item)
            let section = Section()
            section.end = 1
            _sections.append(section)
            _insertedSections.append(0)
            _insertedItems.append(IndexPath(row: 0, section: 0))
        }
        else if linearItemIndex == 0 {
            let neibour = _items[0]
            if neibour.sectionTitle() == item.sectionTitle() {
                _items.insert(item, at: 0)
                _sections[0].end += 1
                _shiftSections(from: 1)
                _insertedItems.append(IndexPath(row: 0, section: 0))
            }
            else {
                let section = Section()
                section.end = 1
                _sections.insert(section, at: 0)
                _items.insert(item, at: 0)
                _shiftSections(from: 1)
                _insertedSections.append(0)
                _insertedItems.append(IndexPath(row: 0, section: 0))
            }
        }
        else if linearItemIndex == _items.count {
            let neibour = _items[_items.count - 1]
            if neibour.sectionTitle() == item.sectionTitle() {
                let s = _sections[_sections.count - 1]
                s.end += 1
                _insertedItems.append(IndexPath(row: s.count - 1, section: _sections.count - 1))
                _items.append(item)
            }
            else {
                let section = Section()
                section.start = _items.count
                section.end = section.start + 1
                _sections.append(section)
                _items.append(item)
                _insertedSections.append(_sections.count - 1)
                _insertedItems.append(IndexPath(row: 0, section: _sections.count - 1))
            }
        }
        else {
            
            let lowerNeibour = _items[linearItemIndex - 1]
            let upperNeibour = _items[linearItemIndex]
            
            if lowerNeibour.sectionTitle() == upperNeibour.sectionTitle() {
                precondition(item.sectionTitle() == lowerNeibour.sectionTitle())
                precondition(item.sectionTitle() == upperNeibour.sectionTitle())
                let sIndex = _sectionIndex(for: linearItemIndex)
                let section = _sections[sIndex]
                section.end += 1
                _shiftSections(from: sIndex + 1)
                let offset = linearItemIndex - section.start
                _items.insert(item, at: linearItemIndex)
                _insertedItems.append(IndexPath(row: offset, section: sIndex))
            }
            else {
                if item.sectionTitle() == lowerNeibour.sectionTitle() {
                    let lowerSectionIndex = _sectionIndex(for: linearItemIndex - 1)
                    let section = _sections[lowerSectionIndex]
                    section.end += 1
                    _shiftSections(from: lowerSectionIndex + 1)
                    _items.insert(item, at: linearItemIndex)
                    _insertedItems.append(IndexPath(row: section.count - 1, section: lowerSectionIndex))
                }
                else if item.sectionTitle() == upperNeibour.sectionTitle() {
                    let lowerSectionIndex = _sectionIndex(for: linearItemIndex)
                    let section = _sections[lowerSectionIndex]
                    section.end += 1
                    _shiftSections(from: lowerSectionIndex + 1)
                    _items.insert(item, at: linearItemIndex)
                    _insertedItems.append(IndexPath(row: section.count - 1, section: lowerSectionIndex))
                }
                else {
                    let lowerSectionIndex = _sectionIndex(for: linearItemIndex - 1)
                    let currentSectionIndex = lowerSectionIndex + 1
                    _shiftSections(from: currentSectionIndex)
                    
                    let lowerSection = _sections[lowerSectionIndex]
                    
                    let section = Section()
                    section.start = lowerSection.end
                    section.end = section.start + 1
                    _sections.insert(section, at: currentSectionIndex)
                    
                    _items.insert(item, at: linearItemIndex)
                    _insertedItems.append(IndexPath(row: 0, section: currentSectionIndex))
                    _insertedSections.append(currentSectionIndex)
                }
            }
        }
        #if DEBUG
        _validateSectionRanges()
        #endif
    }
    
    private func _shiftSections(from: Int, by: Int = 1) {
        for i in from..<_sections.count {
            let s = _sections[i]
            s.start += by
            s.end += by
        }
    }
    
    open func update(_ item: T, at linearItemIndex: Int) {
        precondition(_trackChanges)
        _updates.append(ItemOperation(item, at: linearItemIndex))
    }
    
    private func _update(_ item: T, at linearItemIndex: Int) {
        precondition(_trackChanges)
        let sectionIndex = _sectionIndex(for: linearItemIndex)
        let section = _sections[sectionIndex]
        // NOTE: just update, no any section keys comparing
        _items[linearItemIndex] = item
        _updatedItems.append(IndexPath(row: linearItemIndex - section.start, section: sectionIndex))
    }
    
    open func remove(at linearItemIndex: Int) {
        precondition(_trackChanges)
        _deletions.append(IndexOperation(linearItemIndex))
    }
    
    private func _remove(at linearItemIndex: Int) {
        precondition(_trackChanges)
        
        let sectionIndex = _sectionIndex(for: linearItemIndex)
        let section = _sections[sectionIndex]
        
        section.end -= 1
        
        _removedItems.append(IndexPath(row: linearItemIndex - section.start, section: sectionIndex))
        _items.remove(at: linearItemIndex)
        _shiftSections(from: sectionIndex + 1, by: -1)
        
        if section.isEmpty() {
            _sections.remove(at: sectionIndex)
            _removedSections.append(sectionIndex)
        }
        
        #if DEBUG
        _validateSectionRanges()
        #endif
    }
    
    open func willChange() {
        precondition(!_trackChanges)
        _trackChanges = true
    }
    
    open func linearIndex(at indexPath: IndexPath) -> Int {
        return _sections[indexPath.section].start + indexPath.row
    }
    
    @discardableResult
    open func didChange(returnChanges: Bool = false) -> CacheTrackerSectionedConsumerChanges? {
        
        var changes: CacheTrackerSectionedConsumerChanges?
        
        let job: () -> Void = {
            
            precondition(self._trackChanges)
            
            for (i, s) in self._sections.enumerated() {
                s.sectionTitleBeforeUpdate = self._items[s.start].sectionTitle()
                s.indexBeforeUpdate = i
            }
            
            self.delegate?.cacheTrackerSectionedConsumerBeginUpdates()
            
            self._updatedSections = [Int]()
            self._removedSections = [Int]()
            self._insertedSections = [Int]()
            self._updatedItems = [IndexPath]()
            self._removedItems = [IndexPath]()
            self._insertedItems = [IndexPath]()
            
            self._deletions.sort(by: IndexOperation.comparator(true))
            self._adds.sort(by: IndexOperation.comparator())
            self._updates.sort(by: IndexOperation.comparator())
            
            for o in self._updates {
                self._update(o.item, at: o.index)
            }
            
            self._updates.removeAll()
            
            for o in self._deletions {
                self._remove(at: o.index)
            }
            
            self._deletions.removeAll()
            
            for o in self._adds {
                self._add(o.item, at: o.index)
            }
            
            self._adds.removeAll()
            
            self._updatedItems.sort { (a, b) -> Bool in
                return a <= b
            }
            
            self._removedSections.sort { (a, b) -> Bool in
                return a >= b
            }
            
            self._insertedSections.sort { (a, b) -> Bool in
                return a <= b
            }
            
            self._removedItems.sort { (a, b) -> Bool in
                return a >= b
            }
            
            self._insertedItems.sort { (a, b) -> Bool in
                return a <= b
            }
            
            let deletedSections = Set(self._removedSections)
            
            // We do not want to remove items from already section being deleted
            self._removedItems = self._removedItems.filter({ (o) -> Bool in
                return !deletedSections.contains(o.section)
            })
            
            // If we have inserted section in place of deleted one, then just call
            // reload of section
            for s in self._insertedSections {
                if deletedSections.contains(s) {
                    self._updatedSections.append(s)
                }
            }
            
            let firstStageReloadedSections = Set(self._updatedSections)
            for s in self._sections {
                if s.indexBeforeUpdate != nil {
                    if s.sectionTitleBeforeUpdate != self._items[s.start].sectionTitle() {
                        if !firstStageReloadedSections.contains(s.indexBeforeUpdate!) {
                            self._updatedSections.append(s.indexBeforeUpdate!)
                        }
                    }
                }
            }
            
            let reloadedSections = Set(self._updatedSections)
            
            // reloaded section should not be removed
            self._removedSections = self._removedSections.filter({ (o) -> Bool in
                return !reloadedSections.contains(o)
            })
            
            // reloaded section should not be inserted
            self._insertedSections = self._insertedSections.filter({ (o) -> Bool in
                return !reloadedSections.contains(o)
            })
            
            // If section is reloaded, then there is no need to insert items in such section
            self._insertedItems = self._insertedItems.filter({ (o) -> Bool in
                return !reloadedSections.contains(o.section)
            })
            
            for i in self._updatedItems {
                self.delegate?.cacheTrackerSectionedConsumerDidUpdateItem(at: i)
            }
            
            for i in self._updatedSections {
                self.delegate?.cacheTrackerSectionedConsumerDidUpdateSection(at: i)
            }
            
            for i in self._removedSections {
                self.delegate?.cacheTrackerSectionedConsumerDidRemoveSection(at: i)
            }
            
            for i in self._insertedSections {
                self.delegate?.cacheTrackerSectionedConsumerDidInsertSection(at: i)
            }
            
            for i in self._removedItems {
                self.delegate?.cacheTrackerSectionedConsumerDidRemoveItem(at: i)
            }
            
            for i in self._insertedItems {
                self.delegate?.cacheTrackerSectionedConsumerDidInsertItem(at: i)
            }
            
            if returnChanges {
                changes = CacheTrackerSectionedConsumerChanges(updatedRows: self._updatedItems,
                                                       reloadedSections: self._updatedSections,
                                                       deletedSections: self._removedSections,
                                                       insertedSections: self._insertedSections,
                                                       deletedRows: self._removedItems,
                                                       insertedRows: self._insertedItems)
            }
            
            self._updatedSections = nil
            self._removedSections = nil
            self._insertedSections = nil
            self._removedItems = nil
            self._insertedItems = nil
            self._updatedItems = nil
            
            self._trackChanges = false
            
            self.delegate?.cacheTrackerSectionedConsumerEndUpdates()
        }
        
        
        if (delegate as? NSObject)?.responds(to: #selector(CacheTrackerSectionedConsumerDelegate.cacheTrackerSectionedConsumerBatchUpdates(_:))) == true {
            
            // cacheTrackerSectionedConsumerBatchUpdates could not be used with returnChanges as true
            precondition(returnChanges == false)
            
            delegate!.cacheTrackerSectionedConsumerBatchUpdates! {
                job()
            }
            
            return nil
        }
        
        job()
        
        return changes
    }
    
    open func didChange(block: (_ changes: CacheTrackerSectionedConsumerChanges) -> Void) {
        let changes = didChange(returnChanges: true)!
        block(changes)
    }
    
    open func consume<P>(transactions: [CacheTransaction<P>]) {
        for transaction in transactions {
            switch transaction.type {
            case .insert:
                add(transaction.model! as! T, at: transaction.newIndex!)
            case .delete:
                remove(at: transaction.index!)
            case .update:
                update(transaction.model! as! T, at: transaction.index!)
            case .move:
                remove(at: transaction.index!)
                add(transaction.model! as! T, at: transaction.newIndex!)
            }
        }
    }
    
    #if DEBUG
    private func _validateSectionRanges() {
        guard _sections.count > 0 else {
            precondition(_items.count == 0)
            return
        }
        
        precondition(_sections.first!.start == 0)
        precondition(_sections.last!.end == _items.count)
        precondition(_sections.last!.start < _sections.last!.end)
        
        for i in 0..<(_sections.count - 1) {
            let current = _sections[i]
            let next = _sections[i + 1]
            precondition(current.start < current.end)
            precondition(current.end == next.start)
        }
    }
    #endif//#if DEBUG
}
