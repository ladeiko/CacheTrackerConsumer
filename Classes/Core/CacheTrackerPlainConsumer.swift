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

// Should be called inside performBatchUpdates of UICollectionView
public typealias CacheTrackerPlainConsumerDelegateEndUpdatesBlock = () -> Void

@objc
public protocol CacheTrackerPlainConsumerDelegate {

    //
    // If implemented, then it is called but real updates to consumer are applied when 'applyChangesBlock' is called.
    //
    //  Execution flow:
    //      cacheTrackerPlainConsumerBatchUpdates: { // applyChangesBlock
    //
    //        cacheTrackerPlainConsumerBeginUpdates
    //        cacheTrackerPlainConsumerDidUpdateItem / cacheTrackerPlainConsumerDidRemoveItem / cacheTrackerPlainConsumerDidInsertItem
    //        cacheTrackerPlainConsumerEndUpdates
    //
    //      }
    //
    // NOTE: Should be used when using UICollectionView:
    //
    //  func cacheTrackerPlainConsumerBatchUpdates(_ block: CacheTrackerPlainConsumerDelegateEndUpdatesBlock) {
    //      self.collectionView.performBatchUpdates({
    //          applyChangesBlock() // All changes will be applied to consumer and propagated to UICollectionView.
    //                              // See execution flow described before.
    //      }, completion: nil)
    //  }
    //
    //  See Demo project for examples.
    //
    
    @objc
    optional func cacheTrackerPlainConsumerBatchUpdates(_ applyChangesBlock: @escaping CacheTrackerPlainConsumerDelegateEndUpdatesBlock)
    
    func cacheTrackerPlainConsumerBeginUpdates()
    
    // Updating
    func cacheTrackerPlainConsumerDidUpdateItem(at index: Int)
    func cacheTrackerPlainConsumerDidRemoveItem(at index: Int)
    func cacheTrackerPlainConsumerDidInsertItem(at index: Int)

    // Usefull for UITableView
    func cacheTrackerPlainConsumerEndUpdates()
    
}

public protocol CacheTrackerPlainConsumerUpdatableItem {
    func onWillUpdate(target item: Any)
}

open class CacheTrackerPlainConsumer<T: CacheTrackerPlainModel>: NSObject {
    
    private class IndexOperation {
        weak var linkedIO: IndexOperation?
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
        var movedItem: T?
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

    open func items() -> [T] {
        return _items
    }
    
    open func indexOfItem(by comparator: (_ item: T) -> Bool) -> Int? {
        let count = _items.count
        for i in 0..<count {
            if comparator(_items[i]) {
                return i
            }
        }
        return nil
    }
    
    open func reset<P>(with transactions: [CacheTransaction<P>] = [CacheTransaction<P>](), notifyingDelegate: Bool = false) {
        precondition(!_trackChanges)
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
    
    private func addForMove(_ item: T, at linearItemIndex: Int) -> IndexOperation {
        precondition(_trackChanges)
        let io = ItemOperation(item, at: linearItemIndex)
        _adds.append(io)
        return io
    }
    
    private func _add(_ item: T, at linearItemIndex: Int, accumulate: Bool) {
        
        precondition(_trackChanges)
        precondition(linearItemIndex >= 0 && linearItemIndex <= _items.count)
        
        _items.insert(item, at: linearItemIndex)
        if (accumulate) {
            _insertedItems.append(linearItemIndex)
        }
    }
    
    open func update(_ item: T, at linearItemIndex: Int) {
        precondition(_trackChanges)
        _updates.append(ItemOperation(item, at: linearItemIndex))
    }
    
    private func _update(_ item: T, at linearItemIndex: Int, accumulate: Bool) {
        precondition(_trackChanges)
        if let updatable = item as? CacheTrackerPlainConsumerUpdatableItem {
            updatable.onWillUpdate(target: _items[linearItemIndex])
        }
        _items[linearItemIndex] = item
        if (accumulate) {
            _updatedItems.append(linearItemIndex)
        }
    }
    
    open func remove(at linearItemIndex: Int) {
        precondition(_trackChanges)
        _deletions.append(IndexOperation(linearItemIndex))
    }
    
    private func removeForMove(at linearItemIndex: Int) -> IndexOperation {
        precondition(_trackChanges)
        let io = IndexOperation(linearItemIndex)
        _deletions.append(io)
        return io
    }
    
    private func _remove(at linearItemIndex: Int, accumulate: Bool) {
        precondition(_trackChanges)
        _items.remove(at: linearItemIndex)
        if (accumulate) {
            _removedItems.append(linearItemIndex)
        }
    }
    
    open func willChange() {
        precondition(!_trackChanges)
        _trackChanges = true
    }
    
    @discardableResult
    open func didChange(returnChanges: Bool = false) -> CacheTrackerPlainConsumerChanges? {
        
        var changes: CacheTrackerPlainConsumerChanges?
        let accumulate: Bool = returnChanges || (self.delegate != nil)
        
        let job: () -> Void = {
            
            precondition(self._trackChanges)
            
            self.delegate?.cacheTrackerPlainConsumerBeginUpdates()
            
            if accumulate {
                self._updatedItems = [Int]()
                self._removedItems = [Int]()
                self._insertedItems = [Int]()
            }
            
            self._deletions.sort(by: IndexOperation.comparator(true))
            self._adds.sort(by: IndexOperation.comparator())
            self._updates.sort(by: IndexOperation.comparator())
            
            for o in self._updates {
                self._update(o.item, at: o.index, accumulate: accumulate)
            }
            
            self._updates.removeAll()
            
            for o in self._deletions {
                if let linkedIO = o.linkedIO as? ItemOperation {
                    linkedIO.movedItem = self._items[o.index]
                }
                self._remove(at: o.index, accumulate: accumulate)
            }
            
            self._deletions.removeAll()
            
            for o in self._adds {
                self._add(o.item, at: o.index, accumulate: accumulate)
            }
            
            self._adds.removeAll()
            
            if accumulate {
                
                self._updatedItems.sort { (a, b) -> Bool in
                    return a <= b
                }
                
                self._removedItems.sort { (a, b) -> Bool in
                    return a >= b
                }
                
                self._insertedItems.sort { (a, b) -> Bool in
                    return a <= b
                }
                
                if let delegate = self.delegate {
                    
                    for i in self._updatedItems {
                        delegate.cacheTrackerPlainConsumerDidUpdateItem(at: i)
                    }
                    
                    for i in self._removedItems {
                        delegate.cacheTrackerPlainConsumerDidRemoveItem(at: i)
                    }
                    
                    for i in self._insertedItems {
                        delegate.cacheTrackerPlainConsumerDidInsertItem(at: i)
                    }
                }
                
                if returnChanges {
                    changes = CacheTrackerPlainConsumerChanges(updatedRows: self._updatedItems,
                                                               deletedRows: self._removedItems,
                                                               insertedRows: self._insertedItems)
                }
                
                self._removedItems = nil
                self._insertedItems = nil
                self._updatedItems = nil
            }
            
            self._trackChanges = false
            
            self.delegate?.cacheTrackerPlainConsumerEndUpdates()
        }
        
        if (delegate as? NSObject)?.responds(to: #selector(CacheTrackerPlainConsumerDelegate.cacheTrackerPlainConsumerBatchUpdates(_:))) == true {
            
            // cacheTrackerPlainConsumerBatchUpdates could not be used with returnChanges as true
            precondition(returnChanges == false)
            
            delegate!.cacheTrackerPlainConsumerBatchUpdates! {
                job()
            }
            
            return nil
        }
        
        job()
        
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
                let delIO = removeForMove(at: transaction.index!)
                let addIO = addForMove(transaction.model! as! T, at: transaction.newIndex!)
                delIO.linkedIO = addIO
            }
        }
    }
}
