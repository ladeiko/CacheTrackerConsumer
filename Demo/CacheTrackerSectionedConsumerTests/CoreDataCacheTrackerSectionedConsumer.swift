//
//  CoreDataCacheTrackerSectionedConsumer.swift
//  CacheTrackerSectionedConsumerTests
//
//  Created by Siarhei Ladzeika on 11/4/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import Foundation
import CoreData
import CacheTrackerConsumer

class CoreDataCacheTrackerSectionedConsumer : CacheTrackerSectionedConsumer<SectionedTestItem>, NSFetchedResultsControllerDelegate {
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        willChange()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let item = SectionedTestItem.from(model: anObject)
            add(item, at: newIndexPath!.row)
        case .delete:
            remove(at: indexPath!.row)
        case .move:
            let item = SectionedTestItem.from(model: anObject)
            remove(at: indexPath!.row)
            add(item, at: newIndexPath!.row)
        case .update:
            let item = SectionedTestItem.from(model: anObject)
            update(item, at: indexPath!.row)
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChange()
    }
    
}
