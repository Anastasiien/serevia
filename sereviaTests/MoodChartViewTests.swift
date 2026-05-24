//
//  MoodChartViewTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class MoodChartViewTests: XCTestCase {
    
    private var chartView: MoodChartView!
    
    override func setUp() {
        super.setUp()
        
        chartView = MoodChartView(frame: CGRect(x: 0,
                                                y: 0,
                                                width: 320,
                                                height: 220))
    }
    
    override func tearDown() {
        chartView = nil
        super.tearDown()
    }
    
    // MARK: - testChartRenders()
    
    func testChartRenders() {
        // WHEN
        chartView.configure(with: [
            1: 3,
            2: 4,
            3: 5
        ])
        
        // THEN
        XCTAssertNotNil(chartView)
        XCTAssertEqual(chartView.frame.width, 320)
        XCTAssertEqual(chartView.frame.height, 220)
    }
    
    // MARK: - testChartAcceptsMoodData()
    
    func testChartAcceptsMoodData() {
        // GIVEN
        let data: [Int: Int] = [
            1: 2,
            5: 4,
            10: 5,
            15: 3
        ]
        
        // WHEN
        chartView.configure(with: data)
        
        // THEN
        let mirror = Mirror(reflecting: chartView!)
        
        let storedMoodData = mirror.children.first {
            $0.label == "moodData"
        }?.value as? [Int: Int]
        
        XCTAssertEqual(storedMoodData?.count, 4)
        XCTAssertEqual(storedMoodData?[1], 2)
        XCTAssertEqual(storedMoodData?[10], 5)
    }
    
    // MARK: - testChartHandlesEmptyData()
    
    func testChartHandlesEmptyData() {
        // GIVEN
        let emptyData: [Int: Int] = [:]
        
        // WHEN
        chartView.configure(with: emptyData)
        
        // THEN
        let mirror = Mirror(reflecting: chartView!)
        
        let storedMoodData = mirror.children.first {
            $0.label == "moodData"
        }?.value as? [Int: Int]
        
        XCTAssertTrue(storedMoodData?.isEmpty == true)
    }
    
    // MARK: - testChartUpdates()
    
    func testChartUpdates() {
        // GIVEN
        let initialData: [Int: Int] = [
            1: 2,
            2: 3
        ]
        
        let updatedData: [Int: Int] = [
            1: 5,
            2: 4,
            3: 5
        ]
        
        // WHEN
        chartView.configure(with: initialData)
        chartView.configure(with: updatedData)
        
        // THEN
        let mirror = Mirror(reflecting: chartView!)
        
        let storedMoodData = mirror.children.first {
            $0.label == "moodData"
        }?.value as? [Int: Int]
        
        XCTAssertEqual(storedMoodData?.count, 3)
        XCTAssertEqual(storedMoodData?[1], 5)
        XCTAssertEqual(storedMoodData?[3], 5)
    }
    
    // MARK: - testChartHandlesSinglePoint()
    
    func testChartHandlesSinglePoint() {
        // GIVEN
        let data: [Int: Int] = [
            1: 4
        ]
        
        // WHEN
        chartView.configure(with: data)
        
        // THEN
        let mirror = Mirror(reflecting: chartView!)
        
        let storedMoodData = mirror.children.first {
            $0.label == "moodData"
        }?.value as? [Int: Int]
        
        XCTAssertEqual(storedMoodData?.count, 1)
        XCTAssertEqual(storedMoodData?[1], 4)
    }
    
    // MARK: - testChartHandlesLargeDataset()
    
    func testChartHandlesLargeDataset() {
        // GIVEN
        var data: [Int: Int] = [:]
        
        for day in 1...31 {
            data[day] = Int.random(in: 2...5)
        }
        
        // WHEN
        chartView.configure(with: data)
        
        // THEN
        let mirror = Mirror(reflecting: chartView!)
        
        let storedMoodData = mirror.children.first {
            $0.label == "moodData"
        }?.value as? [Int: Int]
        
        XCTAssertEqual(storedMoodData?.count, 31)
    }
    
    // MARK: - testChartCanDrawWithoutCrash()
    
    func testChartCanDrawWithoutCrash() {
        // GIVEN
        chartView.configure(with: [
            1: 2,
            2: 3,
            3: 5
        ])
        
        // WHEN / THEN
        XCTAssertNoThrow(
            chartView.draw(chartView.bounds)
        )
    }
    
    // MARK: - testChartCanDrawEmptyStateWithoutCrash()
    
    func testChartCanDrawEmptyStateWithoutCrash() {
        // GIVEN
        chartView.configure(with: [:])
        
        // WHEN / THEN
        XCTAssertNoThrow(
            chartView.draw(chartView.bounds)
        )
    }
}
