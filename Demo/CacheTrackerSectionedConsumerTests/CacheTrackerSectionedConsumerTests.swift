//
//  CacheTrackerSectionedConsumerTests.swift
//  CacheTrackerSectionedConsumerTests
//
//  Created by Siarhei Ladzeika.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import XCTest
import MagicalRecord
import CacheTrackerConsumer

@testable import Demo

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: range.lowerBound)
        let idx2 = index(startIndex, offsetBy: range.upperBound)
        return String(self[idx1..<idx2])
    }
}

@objc(CacheTrackerSectionedConsumerTests)
class CacheTrackerSectionedConsumerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_add_0001() {
        /**
         *  [] + AA, BB, CC ->   [AA] [BB] [CC] Single
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.add(SectionedTestItem(name: "CC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
    }
    
    func test_add_0002() {
        /**
         *  [] + AA, BB, CC ->   [AA] [BB] [CC] 2
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
        }

        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        
        array.willChange()
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.insertedSections[0], 1)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 1))
        }
        
        XCTAssertEqual(array.sectionsCount(), 2)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        
        array.willChange()
        array.add(SectionedTestItem(name: "CC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.insertedSections[0], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
    }
    
    func test_add_0003() {
        /**
         *  [AA] [BB] [CC] + CD -> [AA] [BB] [CC CD]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.add(SectionedTestItem(name: "CC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        
        array.willChange()
        array.add(SectionedTestItem(name: "CD"), at: 3)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 1, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 2)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 2)).name, "CD")
    }
    
    func test_add_0004() {
        /**
         *  [AA] [BB] [CC] + BC -> [AA] [BB BC] [CC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.add(SectionedTestItem(name: "CC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        
        array.willChange()
        array.add(SectionedTestItem(name: "BC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 1, section: 1))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 2)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 1)).name, "BC")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
    }
    
    func test_add_0005() {
        /**
         *  [AA] [BB] [CC] + AB + BC + CD -> [AA AB] [BB BC] [CC CD]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.add(SectionedTestItem(name: "CC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        
        array.willChange()
        array.add(SectionedTestItem(name: "AB"), at: 1)
        array.add(SectionedTestItem(name: "BC"), at: 3)
        array.add(SectionedTestItem(name: "CD"), at: 5)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 1, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 1, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 2)
        XCTAssertEqual(array.numberOfItems(at: 1), 2)
        XCTAssertEqual(array.numberOfItems(at: 2), 2)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 1)).name, "BC")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 2)).name, "CD")
    }
    
    func test_add_0006() {
        /**
         *  [AA AC] [BB] [CC] + AB -> [AA AB AC] [BB] [CC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "AC"), at: 1)
        array.add(SectionedTestItem(name: "BB"), at: 2)
        array.add(SectionedTestItem(name: "CC"), at: 3)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 4)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[3], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 2)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AC")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        
        array.willChange()
        array.add(SectionedTestItem(name: "AB"), at: 1)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 1, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
    }
    
    func test_add_0007() {
        /**
         *  [AA AB] + AC -> [AA AB AC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "AB"), at: 1)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 2)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 2)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        
        array.willChange()
        array.add(SectionedTestItem(name: "AC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 2, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
    }
    
    func test_add_0008() {
        /**
         *  [AB AC] + AA -> [AA AB AC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AB"), at: 0)
        array.add(SectionedTestItem(name: "AC"), at: 1)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 2)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 2)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AC")
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
    }
    
    func test_add_0009() {
        /**
         *  [AA AB] + BB -> [AA AB] [BB]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "AB"), at: 1)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 2)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 2)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        
        array.willChange()
        array.add(SectionedTestItem(name: "BB"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.insertedSections[0], 1)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 1))
        }
        
        XCTAssertEqual(array.sectionsCount(), 2)
        XCTAssertEqual(array.numberOfItems(at: 0), 2)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
    }
    
    func test_add_0010() {
        /**
         *  [BB BC] + AA -> [AA] [BB BC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "BB"), at: 0)
        array.add(SectionedTestItem(name: "BC"), at: 1)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 2)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 2)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "BC")
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 2)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 2)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 1)).name, "BC")
    }
    
    func test_remove_0001() {
        /**
         *  [AA AB AC] - AA -> [AB AC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "AB"), at: 1)
        array.add(SectionedTestItem(name: "AC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 2, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
        
        array.willChange()
        array.remove(at: 0)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 1)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.deletedRows[0], IndexPath(row: 0, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 2)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AC")
    }
    
    func test_remove_0002() {
        /**
         *  [AA AB AC] - AC -> [AB AB]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "AB"), at: 1)
        array.add(SectionedTestItem(name: "AC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 2, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
        
        array.willChange()
        array.remove(at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 1)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.deletedRows[0], IndexPath(row: 2, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 2)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
    }
    
    func test_remove_0003() {
        /**
         *  [AA AB AC] - AB -> [AA AC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "AB"), at: 1)
        array.add(SectionedTestItem(name: "AC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 2, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
        
        array.willChange()
        array.remove(at: 1)
        array.didChange()
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 2)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AC")
    }
    
    func test_remove_0004() {
        /**
         *  [AA AB AC] - AA - AB - AC -> []
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "AB"), at: 1)
        array.add(SectionedTestItem(name: "AC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 2, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
        
        array.willChange()
        array.remove(at: 2)
        array.remove(at: 1)
        array.remove(at: 0)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 1)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.deletedSections[0], 0)
        }
        
        XCTAssertEqual(array.sectionsCount(), 0)
    }
    
    func test_remove_0005() {
        /**
         *  [AA] [BB] [CC] - AA -> [BB] [CC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.add(SectionedTestItem(name: "CC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        
        array.willChange()
        array.remove(at: 0)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 1)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.deletedSections[0], 0)
        }
        
        XCTAssertEqual(array.sectionsCount(), 2)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "CC")
    }
    
    func test_remove_0006() {
        /**
         *  [AA] [BB] [CC] - CC -> [AA] [BB]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.add(SectionedTestItem(name: "CC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        
        array.willChange()
        array.remove(at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 1)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.deletedSections[0], 2)
        }
        
        XCTAssertEqual(array.sectionsCount(), 2)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
    }
    
    func test_remove_0007() {
        /**
         *  [AA] [BB] [CC] - BB -> [AA] [CC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.add(SectionedTestItem(name: "CC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        
        array.willChange()
        array.remove(at: 1)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 1)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.deletedSections[0], 1)
        }
        
        XCTAssertEqual(array.sectionsCount(), 2)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "CC")
    }
    
    func test_update_0001() {
        /**
         *  [AA] [BB] [CC] = AA->AC -> [AC] [BB] [CC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.add(SectionedTestItem(name: "CC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        
        array.willChange()
        array.update(SectionedTestItem(name: "AC"), at: 0)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 1)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.updatedRows[0], IndexPath(row: 0, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AC")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
    }
    
    func test_update_0002() {
        /**
         *  [AA] [BB] [CC] = BB->BC -> [AA] [BC] [CC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.add(SectionedTestItem(name: "CC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        
        array.willChange()
        array.update(SectionedTestItem(name: "BC"), at: 1)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 1)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.updatedRows[0], IndexPath(row: 0, section: 1))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BC")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
    }
    
    func test_update_0003() {
        /**
         *  [AA] [BB] [CC] = CC->CD -> [AA] [BB] [CD]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.add(SectionedTestItem(name: "CC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CC")
        
        array.willChange()
        array.update(SectionedTestItem(name: "CD"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 1)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.updatedRows[0], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "CD")
    }
    
    func test_update_0004() {
        /**
         *  [AA AB AC] = AA->AX -> [AX AB AC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "AB"), at: 1)
        array.add(SectionedTestItem(name: "AC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 2, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
        
        array.willChange()
        array.update(SectionedTestItem(name: "AX"), at: 0)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 1)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.updatedRows[0], IndexPath(row: 0, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AX")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
    }
    
    func test_update_0005() {
        /**
         *  [AA AB AC] = AB->AX -> [AA AX AC]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "AB"), at: 1)
        array.add(SectionedTestItem(name: "AC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 2, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
        
        array.willChange()
        array.update(SectionedTestItem(name: "AX"), at: 1)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 1)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.updatedRows[0], IndexPath(row: 1, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AX")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
    }
    
    func test_update_0006() {
        /**
         *  [AA AB AC] = AC->AX -> [AA AB AX]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "AB"), at: 1)
        array.add(SectionedTestItem(name: "AC"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 1, section: 0))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 2, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AC")
        
        array.willChange()
        array.update(SectionedTestItem(name: "AX"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 1)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.updatedRows[0], IndexPath(row: 2, section: 0))
        }
        
        XCTAssertEqual(array.sectionsCount(), 1)
        XCTAssertEqual(array.numberOfItems(at: 0), 3)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 1, section: 0)).name, "AB")
        XCTAssertEqual(array.object(at: IndexPath(row: 2, section: 0)).name, "AX")
    }
    
    func test_mix_0001() {
        /**
         *  [CC] [DD] [EE] - CC - DD + AA + BB -> [AA] [BB] [EE]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "CC"), at: 0)
        array.add(SectionedTestItem(name: "DD"), at: 1)
        array.add(SectionedTestItem(name: "EE"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "CC")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "DD")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "EE")
        
        array.willChange()
        array.remove(at: 1)
        array.remove(at: 0)
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "BB"), at: 1)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 2)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections[0], 0)
            XCTAssertEqual(changes.reloadedSections[1], 1)
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "BB")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "EE")
    }
    
    func test_mix_0002() {
        /**
         *  [CC] [DD] [EE] - CC - DD + AA + FF -> [AA] [BB] [EE]
         */
        
        let array = CacheTrackerSectionedConsumer<SectionedTestItem>()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        array.willChange()
        array.add(SectionedTestItem(name: "CC"), at: 0)
        array.add(SectionedTestItem(name: "DD"), at: 1)
        array.add(SectionedTestItem(name: "EE"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 0)
            XCTAssertEqual(changes.deletedSections.count, 0)
            XCTAssertEqual(changes.insertedSections.count, 3)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedSections[0], 0)
            XCTAssertEqual(changes.insertedSections[1], 1)
            XCTAssertEqual(changes.insertedSections[2], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 0))
            XCTAssertEqual(changes.insertedRows[1], IndexPath(row: 0, section: 1))
            XCTAssertEqual(changes.insertedRows[2], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "CC")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "DD")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "EE")
        
        array.willChange()
        array.remove(at: 1)
        array.remove(at: 0)
        array.add(SectionedTestItem(name: "AA"), at: 0)
        array.add(SectionedTestItem(name: "FF"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.reloadedSections.count, 1)
            XCTAssertEqual(changes.deletedSections.count, 1)
            XCTAssertEqual(changes.insertedSections.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.reloadedSections[0], 0)
            XCTAssertEqual(changes.deletedSections[0], 1)
            XCTAssertEqual(changes.insertedSections[0], 2)
            XCTAssertEqual(changes.insertedRows[0], IndexPath(row: 0, section: 2))
        }
        
        XCTAssertEqual(array.sectionsCount(), 3)
        XCTAssertEqual(array.numberOfItems(at: 0), 1)
        XCTAssertEqual(array.numberOfItems(at: 1), 1)
        XCTAssertEqual(array.numberOfItems(at: 2), 1)
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 0)).name, "AA")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 1)).name, "EE")
        XCTAssertEqual(array.object(at: IndexPath(row: 0, section: 2)).name, "FF")
    }
    
    func testWithNSFetchedResultsController() {
        
        defer {
            MagicalRecord.cleanUp()
        }
        
        MagicalRecord.setLoggingLevel(.off)
        MagicalRecord.cleanUp()
        MagicalRecord.setDefaultModelFrom(type(of: self).self)
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
        
        let array = CoreDataCacheTrackerSectionedConsumer()
        XCTAssertEqual(array.sectionsCount(), 0)
        
        let tableView = SectionedTableView(adapter: array)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.frame = UIApplication.shared.keyWindow!.bounds
        UIApplication.shared.keyWindow?.addSubview(tableView)

        let defaultContext = NSManagedObjectContext.mr_default()
        let fetchRequest = NSFetchRequest<TestModel>(entityName: NSStringFromClass(TestModel.self))
        fetchRequest.predicate = NSPredicate(value: true)
        
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TestModel.section), ascending: true),
            NSSortDescriptor(key: #keyPath(TestModel.name), ascending: true)
        ]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: defaultContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = array
        try! controller.performFetch()
        
        let checkTableView: () -> Void = {
            
            let visibleCells = tableView.visibleCells
            
            let visibleValues = visibleCells.map { cell -> String in
                return cell.textLabel!.text!
            }
            
            let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows
            
            let visibleCount = indexPathsForVisibleRows?.count ?? 0
            
            guard visibleCount > 0 else {
                defaultContext.performAndWait {
                    let count = TestModel.mr_countOfEntities(with: NSPredicate(value: true), in: defaultContext)
                    XCTAssertEqual(count, 0)
                }
                return
            }
            
            let topVisibleIndexPath = indexPathsForVisibleRows![0]
            let linearVisibleTopIndex = array.linearIndex(at: topVisibleIndexPath)
            
            let request = NSFetchRequest<TestModel>(entityName: NSStringFromClass(TestModel.self))
            request.predicate = NSPredicate(value: true)
            request.sortDescriptors = sortDescriptors
            request.fetchOffset = linearVisibleTopIndex
            request.fetchLimit = visibleCount
            
            defaultContext.performAndWait {
                let databaseValues = try! defaultContext.fetch(request).map({ (model) -> String in
                    return model.name!
                })
                
                XCTAssertEqual(databaseValues, visibleValues)
            }
        }
        
        let microTest = { (initials: [String], changes: [String], result: [[String]]) in
            
            let expectation = XCTestExpectation(description: "")
            
            TestModel.mr_deleteAll(matching: NSPredicate(value: true), in: defaultContext)
            
            let sections = NSMutableDictionary()
            defaultContext.mr_save(blockAndWait: { (context) in
                for i in initials {
                    let modelA = TestModel.mr_createEntity(in: context)!
                    let sectionName = String(i.prefix(1))
                    modelA.name = i
                    modelA.section = sectionName
                    
                    if sections[sectionName] == nil {
                        sections[sectionName] = NSMutableArray(objects: i)
                    }
                    else {
                        let o = sections[sectionName] as! NSMutableArray
                        o.add(i)
                    }
                }
            })
            
            let keys = sections.allKeys.sorted(by: { (s1, s2) -> Bool in
                let s1 = s1 as! String
                let s2 = s2 as! String
                return s1 <= s2
            })
            
            XCTAssertEqual(array.sectionsCount(), sections.count)
            for (i, k) in keys.enumerated() {
                let p = sections[k] as! NSMutableArray
                XCTAssertEqual(array.numberOfItems(at: i), p.count)
            }
            
            for (s, k) in keys.enumerated() {
                let objects = (sections[k] as! NSMutableArray).sorted(by: { (o1, o2) -> Bool in
                    let o1 = o1 as! String
                    let o2 = o2 as! String
                    return o1 <= o2
                })
                
                for (j, o) in objects.enumerated() {
                    XCTAssertEqual(array.object(at: IndexPath(row: j, section: s)).name, o as! String)
                }
            }
            
            DispatchQueue.global().async {
                let currentContext = NSManagedObjectContext.mr_context(withParent: defaultContext)
                
                currentContext.mr_save ({ (context) in
                    
                    let deletions = NSMutableArray()
                    let insertions = NSMutableArray()
                    let moves = NSMutableArray()
                    
                    for change in changes {
                        switch String(change.prefix(1)) {
                        case "+":
                            insertions.add(String(change[1..<change.count]))
                        case "-":
                            let item = TestModel.mr_findFirst(with: NSPredicate(format: "name = %@", String(change[1..<change.count])),
                                                              in: context)!
                            deletions.add(item)
                        default:
                            let p = change.components(separatedBy: "->")
                            XCTAssertTrue(p.count == 2)
                            let was = String(p[0])
                            let became = String(p[1])
                            let item = TestModel.mr_findFirst(with: NSPredicate(format: "name = %@", was), in: context)!
                            moves.add([item, became])
                        }
                    }
                    
                    for d in deletions {
                        let d = d as! TestModel
                        d.mr_deleteEntity(in: context)
                    }
                    
                    for i in insertions {
                        let e = TestModel.mr_createEntity(in: context)!
                        let i = i as! String
                        e.name = i
                        e.section = String(i.prefix(1))
                    }
                    
                    for m in moves {
                        let m = m as! [Any]
                        let i = m[0] as! TestModel
                        let n = m[1] as! String
                        i.name = n
                        i.section = String(n.prefix(1))
                    }
                    
                }, completion: { (_, _) in
                    expectation.fulfill()
                    
                })
            }
            
            self.wait(for: [expectation], timeout: 10.0)
            
            XCTAssertEqual(result.count, array.sectionsCount())
            for (i, s) in result.enumerated() {
                XCTAssertEqual(result[i].count, array.numberOfItems(at: i))
                for (j, r) in s.enumerated() {
                    XCTAssertEqual(r, array.object(at: IndexPath(row: j, section: i)).name)
                }
            }
            
            checkTableView()
        }
        
        // [] +AA +BB => [AA] [BB]
        microTest([],
                  [ "+AA", "+BB" ],
                  [ [ "AA" ], [ "BB" ] ])
        
        // [AA] [BB] AA->CC => [BB] [CC]
        microTest([ "AA", "BB" ],
                  [ "AA->CC"],
                  [ [ "BB" ], [ "CC" ] ])
        
        // [BB] [CC] +AA => [AA] [BB] [CC]
        microTest([ "BB", "CC" ],
                  [ "+AA"],
                  [ [ "AA" ], [ "BB" ], [ "CC" ] ])
        
        // [AA] [BB] [CC] -AA BB->CC CC->BB => [BB] [CC]
        microTest([ "AA", "BB", "CC" ],
                  [ "-AA", "BB->CC", "CC->BB" ],
                  [ [ "BB" ], [ "CC" ] ])
        
        // [CC] [DD] [EE] -CC -DD + AA + BB => [AA] [BB] [EE]
        microTest([ "CC", "DD", "EE" ],
                  [ "-CC", "-DD", "+AA", "+BB" ],
                  [ [ "AA" ], [ "BB" ], [ "EE" ] ])
        
        // [CC] [DD] [EE] -CC -DD -EE => []
        microTest([ "CC", "DD", "EE" ],
                  [ "-CC", "-DD", "-EE" ],
                  [])
        
        // [AA AB] AA->AB AB->AA => [AA AB]
        microTest([ "AA", "AB" ],
                  [ "AA->AB", "AB->AA"],
                  [ [ "AA", "AB" ] ])
        
        // [AA AB] [BB] [CC CD] AA->CC AB->CD CC->AA CD->AB => [AA AB] [BB] [CC CD]
        microTest(["AA", "AB", "BB", "CC", "CD"],
                  [ "AA->CC", "AB->CD", "CC->AA", "CD->AB"],
                  [ [ "AA", "AB" ], [ "BB" ], [ "CC", "CD" ] ])
        
        // [AA AB AC] -AA AB->AC AC->AB => [AB AC]
        microTest(["AA", "AB", "AC"],
                  [ "-AA", "AB->AC", "AC->AB"],
                  [ [ "AB", "AC" ] ])
        
        // [AA] [BB] [CC] -AA BB->CC CC->BB => [BB CC]
        microTest(["AA", "BB", "CC"],
                  [ "-AA", "BB->CC", "CC->BB"],
                  [ [ "BB" ], [ "CC" ] ])
        
        // [CC] [DD] [EE] - CC - DD + AA + FF => [AA] [EE] [FF]
        microTest([ "CC", "DD", "EE" ],
                  [ "-CC", "-DD", "+AA", "+FF" ],
                  [ [ "AA" ], [ "EE" ], [ "FF" ] ])
        
        // [CC CD] [DD DE] [EE] -CC -CD -DD -DE + AA + FF => [AA] [EE] [FF]
        microTest([ "CC", "CD", "DD", "DE", "EE" ],
                  [ "-CC", "-CD", "-DD", "-DE", "+AA", "+FF" ],
                  [ [ "AA" ], [ "EE" ], [ "FF" ] ])
    }
    
}
