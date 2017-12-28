//
//  PlainTableViewController.swift
//  Demo
//
//  Created by Siarhei Ladzeika on 11/10/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import UIKit
import CacheTracker
import MagicalRecord
import RandomKit
import CacheTrackerConsumer

class PlainTableViewController: UITableViewController, CacheTrackerDelegate {
    
    typealias P = PlainItem
    
    var context: NSManagedObjectContext!
    var cacheTracker: CoreDataCacheTracker<CoreDataItem, PlainItem>!
    var consumer: CacheTrackerPlainConsumer<PlainItem>!
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cacheTrackerSectionOffset = 2
        self.cacheTrackerItemsOffset = 1
        
        self.navigationItem.title = self.title
        
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
                let value = UInt.random(using: &Xoroshiro.default) % 4
                
                switch value {
                case 0:
                    DispatchQueue.global().async {
                        let  context = NSManagedObjectContext.mr_context(withParent: self.context)
                        context.mr_save( blockAndWait: { (context) in
                            if CoreDataItem.mr_countOfEntities(with: context) > 10 {
                                return
                            }
                            let value = UInt.random(using: &Xoroshiro.default)
                            let item = CoreDataItem.mr_createEntity(in: context)!
                            item.name = "\(value)"
                            item.section = String(item.name!.prefix(1))
                        })
                    }
                    
                case 1:
                    DispatchQueue.global().async {
                        let  context = NSManagedObjectContext.mr_context(withParent: self.context)
                        context.mr_save( blockAndWait: { (context) in
                            let items = CoreDataItem.mr_findAll(with: NSPredicate(value: true), in: context)!
                            let count = items.count
                            if  count > 1 {
                                let target = abs(Int.random(using: &Xoroshiro.default)) % count
                                items[target].mr_deleteEntity(in: context)
                            }
                        })
                    }
                    
                case 2:
                   break
                    
                default:
                    DispatchQueue.global().async {
                        let  context = NSManagedObjectContext.mr_context(withParent: self.context)
                        context.mr_save( blockAndWait: { (context) in
                            let items = CoreDataItem.mr_findAll(with: NSPredicate(value: true), in: context)!
                            let count = items.count
                            if  count > 1 {
                                let target = abs(Int.random(using: &Xoroshiro.default)) % count
                                let value = UInt.random(using: &Xoroshiro.default)
                                let item = items[target] as! CoreDataItem
                                item.name = "\(value)"
                                item.section = String(item.name!.prefix(1))
                            }
                        })
                    }
                }
            })
        }
        
        if context == nil {
             context = NSManagedObjectContext.mr_default()
        }
        
        context.mr_save( blockAndWait: { (context) in
            CoreDataItem.mr_deleteAll(matching: NSPredicate(value: true), in: context)
            for _ in 0..<3 {
                let item = CoreDataItem.mr_createEntity(in: context)!
                let value = UInt.random(using: &Xoroshiro.default)
                item.name = "\(value)"
                item.section = String(item.name!.prefix(1))
            }
        })
        
        consumer = CacheTrackerPlainConsumer<PlainItem>()
        consumer.delegate = self
        
        cacheTracker = CoreDataCacheTracker<CoreDataItem, PlainItem>(context: NSManagedObjectContext.mr_default())
        cacheTracker.delegate = self
        let cacheRequest = CacheRequest(predicate: NSPredicate(value: true), sortDescriptors: [
            NSSortDescriptor(key: #keyPath(CoreDataItem.name), ascending: true)
            ])
        cacheTracker.fetchWithRequest(cacheRequest)
        
        consumer.reset(with: cacheTracker.transactionsForCurrentState(), notifyingDelegate: false)
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.globalSectionCount(1)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isPlainDataSection(section) {
            return consumer.numberOfItems() + cacheTrackerItemsOffset
        }
        else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isPlainDataIndexPath(indexPath) {
            return tableView.dequeueReusableCell(withIdentifier: "Default")!
        }
        else {
            return tableView.dequeueReusableCell(withIdentifier: "Before")!
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.isPlainDataIndexPath(indexPath) {
            let item = consumer.object(at: self.plainIndexPath(from: indexPath).row)
            cell.textLabel?.text = item.name
        }
        else {
            cell.textLabel?.text = "Before \(indexPath)"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - CacheTrackerDelegate
    
    func cacheTrackerShouldMakeInitialReload() {
        guard isViewLoaded else {
            return
        }
        
        tableView.reloadData()
    }
    
    func cacheTrackerBeginUpdates() {
        consumer.willChange()
    }
    
    func cacheTrackerEndUpdates() {
        consumer.didChange()
    }
    
    func cacheTrackerDidGenerate<P>(transactions: [CacheTransaction<P>]) {
        for transaction in transactions {
            switch transaction.type {
            case .insert:
                consumer.add(transaction.model as! PlainItem, at: transaction.newIndex!)
            case .delete:
                consumer.remove(at: transaction.index!)
            case .update:
                consumer.update(transaction.model as! PlainItem, at: transaction.index!)
            case .move:
                consumer.remove(at: transaction.index!)
                consumer.add(transaction.model as! PlainItem, at: transaction.newIndex!)
            }
        }
    }
    
}

