//
//  CacheTrackerPlainConsumer.swift
//
//  Created by Siarhei Ladzeika on 11/3/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import Foundation
import CacheTracker

@objc open class CacheTrackerPlainConsumerChanges: NSObject {
    
    open let updatedRows: [Int]!
    open let deletedRows: [Int]!
    open let insertedRows: [Int]!
    
    init(updatedRows: [Int], deletedRows: [Int], insertedRows: [Int]) {
        self.updatedRows = updatedRows
        self.deletedRows = deletedRows
        self.insertedRows = insertedRows
    }
}

@objc public protocol CacheTrackerPlainConsumerDelegate {
    func cacheTrackerPlainConsumerBeginUpdates()
    func cacheTrackerPlainConsumerDidUpdateItem(at index: Int)
    func cacheTrackerPlainConsumerDidRemoveItem(at index: Int)
    func cacheTrackerPlainConsumerDidInsertItem(at index: Int)
    func cacheTrackerPlainConsumerEndUpdates()
}

open class CacheTrackerPlainConsumer<T: CacheTrackerPlainModel>: NSObject {
    
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
    
    open weak var delegate: CacheTrackerPlainConsumerDelegate?
    
    private var _adds: [ItemOperation] = [ItemOperation]()
    private var _deletions: [IndexOperation] = [IndexOperation]()
    private var _updates: [ItemOperation] = [ItemOperation]()
    private var _trackChanges = false
    private var _items: [T] = [T]()
    private var _updatedItems: [Int]!
    private var _removedItems: [Int]!
    private var _insertedItems: [Int]!
    
    open func numberOfItems() -> Int {
        return _items.count
    }
    
    open func object(at index: Int) -> T {
        return _items[index]
    }
    
    open func reset() {
        precondition(!_trackChanges)
        _items.removeAll()
    }
    
    open func add(_ item: T, at linearItemIndex: Int) {
        precondition(_trackChanges)
        _adds.append(ItemOperation(item, at: linearItemIndex))
    }
    
    private func _add(_ item: T, at linearItemIndex: Int) {
        
        precondition(_trackChanges)
        precondition(linearItemIndex >= 0 && linearItemIndex <= _items.count)
        
        _items.insert(item, at: linearItemIndex)
        _insertedItems.append(linearItemIndex)
    }
    
    open func update(_ item: T, at linearItemIndex: Int) {
        precondition(_trackChanges)
        _updates.append(ItemOperation(item, at: linearItemIndex))
    }
    
    private func _update(_ item: T, at linearItemIndex: Int) {
        precondition(_trackChanges)
        // NOTE: just update, no any section keys comparing
        _items[linearItemIndex] = item
        _updatedItems.append(linearItemIndex)
    }
    
    open func remove(at linearItemIndex: Int) {
        precondition(_trackChanges)
        _deletions.append(IndexOperation(linearItemIndex))
    }
    
    private func _remove(at linearItemIndex: Int) {
        precondition(_trackChanges)
        _removedItems.append(linearItemIndex)
        _items.remove(at: linearItemIndex)
    }
    
    open func willChange() {
        precondition(!_trackChanges)
        _trackChanges = true
    }
    
    @discardableResult
    open func didChange(returnChanges: Bool = false) -> CacheTrackerPlainConsumerChanges? {
        
        precondition(_trackChanges)
        
        delegate?.cacheTrackerPlainConsumerBeginUpdates()
        
        _updatedItems = [Int]()
        _removedItems = [Int]()
        _insertedItems = [Int]()
        
        _deletions.sort(by: IndexOperation.comparator(true))
        _adds.sort(by: IndexOperation.comparator())
        _updates.sort(by: IndexOperation.comparator())
        
        for o in _updates {
            _update(o.item, at: o.index)
        }
        
        _updates.removeAll()
        
        for o in _deletions {
            _remove(at: o.index)
        }
        
        _deletions.removeAll()
        
        for o in _adds {
            _add(o.item, at: o.index)
        }
        
        _adds.removeAll()
        
        _updatedItems.sort { (a, b) -> Bool in
            return a <= b
        }
        
        _removedItems.sort { (a, b) -> Bool in
            return a >= b
        }
        
        _insertedItems.sort { (a, b) -> Bool in
            return a <= b
        }
        
        for i in _updatedItems {
            delegate?.cacheTrackerPlainConsumerDidUpdateItem(at: i)
        }
        
        for i in _removedItems {
            delegate?.cacheTrackerPlainConsumerDidRemoveItem(at: i)
        }
        
        for i in _insertedItems {
            delegate?.cacheTrackerPlainConsumerDidInsertItem(at: i)
        }
        
        var changes: CacheTrackerPlainConsumerChanges?
        if returnChanges {
            changes = CacheTrackerPlainConsumerChanges(updatedRows: _updatedItems,
                                                   deletedRows: _removedItems,
                                                   insertedRows: _insertedItems)
        }
        
        _removedItems = nil
        _insertedItems = nil
        _updatedItems = nil
        
        _trackChanges = false
        
        delegate?.cacheTrackerPlainConsumerEndUpdates()
        return changes
    }
    
    open func didChange(block: (_ changes: CacheTrackerPlainConsumerChanges) -> Void) {
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
}
