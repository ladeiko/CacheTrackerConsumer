# CHANGELOG

## 1.5.0
### Added
* CacheTrackerPlainRecurrentConsumer class and CacheTrackerPlainRecurrentConsumerItem protocol

## 1.4.0
### Added
* 'cacheTrackerSectionedConsumerBatchUpdates' to both consumer delegates. This helps to implemented proper interaction with UICollectionView - apply all changes from 'performBatchUpdates'.

## 1.3.1
### Added
* Dispatching of Objective-C try/catch while applyting changes to UICollectionView/UITableView. Now if any exception is generated while update, then view is reloaded with 'reloadData'.

## 1.3.0

### Added
* Add

```swift 
open func items() -> [T]
```
and 

```swift 
func indexOfItem(by comparator: (_ item: T) -> Bool) -> Int?
``` 

to CacheTrackerPlainConsumer
  
## 1.2.0

### Added
* New properties:
  * var cacheTrackerItemsOffset: Int = 0 (used only in plain mode)
  * var cacheTrackerSectionOffset: Int = 0 (used in both modes)
  
## 1.1.0

### Changed
 * Changes signature of method **reset()*:

 ```swift
 open func reset<P>(with transactions: [CacheTransaction<P>] = [CacheTransaction<P>](), 
 		notifyingDelegate: Bool = false)
 ```
If notifyingDelegate is false (by default), then you should reload your table or collection view after calling this
method.