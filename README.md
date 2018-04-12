# CacheTrackerConsumer

Helper classes for use as mediator between [CacheTracker](https://github.com/ladeiko/CacheTracker) and UI controls (UITableView, UICollectionView). It keeps local one or two dimentional array of items in sync with cache tracker storage. UI controls can interact with consumer directly. This is very helpful when you use VIPER architecture. You place consumer in VIEW and pass transactions from INTERACTOR through PRESENTER to your VIEW. VIEW in this case stays passive as VIPER rules requires and its state is controlled from PRESENTER only.

## Changes

### v1.3.1

* Add dispatching of Objective-C try/catch while applyting changes to UICollectionView/UITableView. Now if any exception is generated while update, then view is reloaded with 'reloadData'.

### v1.3.0

* Add

```swift 
open func items() -> [T]
```
and 

```swift 
func indexOfItem(by comparator: (_ item: T) -> Bool) -> Int?
``` 

to CacheTrackerPlainConsumer
  
### v1.2.0

* New properties:
  * var cacheTrackerItemsOffset: Int = 0 (used only in plain mode)
  * var cacheTrackerSectionOffset: Int = 0 (used in both modes)
  
### v1.1.0

 * Changes signature of method **reset()*:

 ```swift
 open func reset<P>(with transactions: [CacheTransaction<P>] = [CacheTransaction<P>](), 
 		notifyingDelegate: Bool = false)
 ```
If notifyingDelegate is false (by default), then you should reload your table or collection view after calling this
method.

## Types

### CacheTrackerPlainConsumer

Just keep plain items in linear array in sync with cache tracker storage and generates updates for UI controls.

### CacheTrackerSectionedConsumer

Just keep plain items in sectioned array in sync with cache tracker storage and generates updates for UI controls. Cache tracker generates linear array of plain items, but they are converted to sectioned array and UI controls think they work with sections.
You can say that "why do not use direct section notifications from CacheTracker" - and the answer is: i spent **two weeks** for analyzing behaviour of notifications generated by CoreData/Realm FRC, i understood, that it is "hell" when you try to use sections in FRC, and there is no normal way to keep items in own two dimentional array in sync with storage managed by only FRC, so i decided to write these classes to make it easy.

**NOTE**: If you have millions of items, then i recommend to you direct interaction of VIEW with CacheTracker, because of performance issue.

## Usage
To use with CacheTrackerSectionedConsumer just make your plain model compatibel with CacheTrackerSectionedConsumerModel protocol.
For complete examples see Demo project.

```swift
class PlainItem: CacheTrackerPlainModel, CacheTrackerSectionedConsumerModel {
    
    let name: String
    let section: String
    
    init(name: String) {
        self.name = name
        self.section = String(name.prefix(1))
    }
    
    // MARK: - CacheTrackerPlainModel
    
    required init() {
        self.name = ""
        self.section = ""
    }
    
    // MARK: - CacheTrackerSectionedConsumerModel
    
    func sectionTitle() -> String {
        return self.section
    }

}
```

Create consumer and set its delegate

```swift
consumer = CacheTrackerSectionedConsumer<PlainItem>()
consumer.delegate = self
```

When you use CacheTrackerSectionedConsumer then do not forget to pass section key as first sort descriptor (in this example we want to use 'section' as section key)

```swift
let cacheRequest = CacheRequest(predicate: NSPredicate(value: true), sortDescriptors: [
    NSSortDescriptor(key: #keyPath(CoreDataItem.section), ascending: true),
    NSSortDescriptor(key: #keyPath(CoreDataItem.name), ascending: true)
    ])
```

Fill up consumer with initial set of objects if required

* using animated insert

```swift
consumer.willChange()
consumer.consume(transactions: cacheTracker.transactionsForCurrentState())
consumer.didChange()
```

* complete reload

```swift
consumer.reset(with: cacheTracker.transactionsForCurrentState())
tableView.reloadData()
```

**NOTE**: You should call *willChange()* before any batch calls to *consume()*, *add()*, *remove()*, *update()* of consumer. After all batch operations were called you have to complete interaction with *didChange()* as in example above.

Implement table view datasource (or collection view), where you will refer to consumer methods:

* where cacheTrackerSectionOffset == 0 and cacheTrackerItemsOffset == 0 (by default)

```swift
override func numberOfSections(in tableView: UITableView) -> Int {
    return consumer.sectionsCount()
}
    
override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return consumer.numberOfItems(at: section)
}
    
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "Default")!
}
    
override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let item = consumer.object(at: indexPath)
    cell.textLabel?.text = item.name
}
    
override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let item = consumer.object(at: IndexPath(row: 0, section: section))
    return item.section
}
```

* where cacheTrackerSectionOffset > 0 or cacheTrackerItemsOffset > 0

```swift
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
```

### Offsets

If you want to show items not from the beginning, then you can set offsets using:
  * var cacheTrackerItemsOffset: Int = 0
  * var cacheTrackerSectionOffset: Int = 0

They control offset of data section / items from the beginning of the tableView or collectionView.

For more detailed example see Demo project

## Installation

### Cocoapods

Add to you Podfile

```ruby
pod 'CacheTrackerConsumer'
```

If you want to use UIKit extensions

```ruby
pod 'CacheTrackerConsumer'
pod 'CacheTrackerConsumer/UIKit'
```

UIKit extensions contains default implementations of *CacheTrackerPlainConsumerDelegate* (or *CacheTrackerSectionedConsumerDelegate*) for *UITableView*, *UICollectionView*, *UITableViewController*, *UICollectionViewController*, etc...

And finally import the module

```swift
import CacheTrackerConsumer
```
