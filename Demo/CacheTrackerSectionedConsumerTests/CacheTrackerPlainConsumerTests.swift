//
//  CacheTrackerPlainConsumerTests.swift
//  CacheTrackerSectionedConsumerTests
//
//  Created by Siarhei Ladzeika on 6/25/18.
//  Copyright © 2018 Siarhei Ladzeika. All rights reserved.
//

import XCTest
import MagicalRecord
import CacheTrackerConsumer
import CacheTracker

@testable import Demo

@objc(CacheTrackerPlainConsumerTests)
class CacheTrackerPlainConsumerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_add_0001() {
        /**
         *  [] + A, B, C ->   [A] [B] [C]
         */
        
        let array = CacheTrackerPlainConsumer<TestItem>()
        XCTAssertEqual(array.numberOfItems(), 0)
        
        array.willChange()
        array.add(TestItem(name: "A", section: "1"), at: 0)
        array.add(TestItem(name: "B", section: "2"), at: 1)
        array.add(TestItem(name: "C", section: "3"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedRows[0], 0)
            XCTAssertEqual(changes.insertedRows[1], 1)
            XCTAssertEqual(changes.insertedRows[2], 2)
        }
        
        XCTAssertEqual(array.numberOfItems(), 3)
        XCTAssertEqual(array.object(at: 0).name, "A")
        XCTAssertEqual(array.object(at: 1).name, "B")
        XCTAssertEqual(array.object(at: 2).name, "C")
    }
    
    func test_update_0001() {
        /**
         *  [] + A, B, C ->   [D] [B] [C]
         */
        
        let array = CacheTrackerPlainConsumer<TestItem>()
        XCTAssertEqual(array.numberOfItems(), 0)
        
        array.willChange()
        array.add(TestItem(name: "A", section: "1"), at: 0)
        array.add(TestItem(name: "B", section: "2"), at: 1)
        array.add(TestItem(name: "C", section: "3"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedRows[0], 0)
            XCTAssertEqual(changes.insertedRows[1], 1)
            XCTAssertEqual(changes.insertedRows[2], 2)
        }
        
        XCTAssertEqual(array.numberOfItems(), 3)
        XCTAssertEqual(array.object(at: 0).name, "A")
        XCTAssertEqual(array.object(at: 1).name, "B")
        XCTAssertEqual(array.object(at: 2).name, "C")
        
        XCTAssertEqual(array.object(at: 0).section, "1")
        XCTAssertEqual(array.object(at: 1).section, "2")
        XCTAssertEqual(array.object(at: 2).section, "3")
        
        array.willChange()
        array.update(TestItem(name: "D", section: "100"), at: 0)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 1)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 0)
            XCTAssertEqual(changes.updatedRows[0], 0)
        }
        
        XCTAssertEqual(array.numberOfItems(), 3)
        XCTAssertEqual(array.object(at: 0).name, "D")
        XCTAssertEqual(array.object(at: 1).name, "B")
        XCTAssertEqual(array.object(at: 2).name, "C")
        
        XCTAssertEqual(array.object(at: 0).section, "100")
        XCTAssertEqual(array.object(at: 1).section, "2")
        XCTAssertEqual(array.object(at: 2).section, "3")
        
    }
    
    func test_move_0001() {
        /**
         *  [] + A, B, C ->   [D] [B] [C]
         */
        
        let array = CacheTrackerPlainConsumer<TestItem>()
        XCTAssertEqual(array.numberOfItems(), 0)
        
        array.willChange()
        array.add(TestItem(name: "A", section: "1"), at: 0)
        array.add(TestItem(name: "B", section: "2"), at: 1)
        array.add(TestItem(name: "C", section: "3"), at: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 0)
            XCTAssertEqual(changes.insertedRows.count, 3)
            XCTAssertEqual(changes.insertedRows[0], 0)
            XCTAssertEqual(changes.insertedRows[1], 1)
            XCTAssertEqual(changes.insertedRows[2], 2)
        }
        
        XCTAssertEqual(array.numberOfItems(), 3)
        XCTAssertEqual(array.object(at: 0).name, "A")
        XCTAssertEqual(array.object(at: 1).name, "B")
        XCTAssertEqual(array.object(at: 2).name, "C")
        
        let moved = TestItem(name: "D", section: "100")
        
        array.willChange()
        array.move(moved, from: 0, to: 2)
        array.didChange { changes in
            XCTAssertEqual(changes.updatedRows.count, 0)
            XCTAssertEqual(changes.deletedRows.count, 1)
            XCTAssertEqual(changes.insertedRows.count, 1)
            XCTAssertEqual(changes.deletedRows[0], 0)
            XCTAssertEqual(changes.insertedRows[0], 2)
        }
        
        XCTAssertEqual(array.numberOfItems(), 3)
        XCTAssertEqual(array.object(at: 0).name, "B")
        XCTAssertEqual(array.object(at: 1).name, "C")
        XCTAssertEqual(array.object(at: 2).name, "D")
        
        XCTAssertEqual(array.object(at: 0).section, "2")
        XCTAssertEqual(array.object(at: 1).section, "3")
        XCTAssertEqual(array.object(at: 2).section, "100")
        
    }
    
}
