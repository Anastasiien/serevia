//
//  TestHistoryViewControllerTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class TestHistoryViewControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "testHistory")
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "testHistory")
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    private func makeViewController() -> TestHistoryViewController {
        let vc = TestHistoryViewController()
        vc.loadViewIfNeeded()
        return vc
    }
    
    private func saveMockHistory(_ results: [TestResult]) {
        let data = try! JSONEncoder().encode(results)
        UserDefaults.standard.set(data, forKey: "testHistory")
    }
    
    private func extractTableView(from vc: UIViewController) -> UITableView? {
        return vc.view.subviews.first(where: { $0 is UITableView }) as? UITableView
    }
    
    // MARK: - Tests
    
    func testHistoryLoads() {
        // GIVEN
        let result = TestResult(
            testName: "Beck Test",
            score: 15,
            date: Date(),
            status: "Средняя тревожность"
        )
        
        saveMockHistory([result])
        
        // WHEN
        let vc = makeViewController()
        let tableView = extractTableView(from: vc)
        
        // THEN
        XCTAssertNotNil(tableView)
        
        let rows = tableView?.numberOfRows(inSection: 0)
        XCTAssertEqual(rows, 1)
    }
    
    func testHistoryDisplays() {
        // GIVEN
        let result = TestResult(
            testName: "Mindfulness Test",
            score: 25,
            date: Date(),
            status: "Высокий уровень"
        )
        
        saveMockHistory([result])
        
        // WHEN
        let vc = makeViewController()
        let tableView = extractTableView(from: vc)!
        
        let cell = vc.tableView(
            tableView,
            cellForRowAt: IndexPath(row: 0, section: 0)
        )
        
        // THEN
        XCTAssertTrue(cell is TestHistoryCell)
    }
    
    func testEmptyHistoryState() {
        // GIVEN
        UserDefaults.standard.removeObject(forKey: "testHistory")
        
        // WHEN
        let vc = makeViewController()
        let tableView = extractTableView(from: vc)!
        
        let rows = vc.tableView(tableView, numberOfRowsInSection: 0)
        let cell = vc.tableView(
            tableView,
            cellForRowAt: IndexPath(row: 0, section: 0)
        )
        
        // THEN
        XCTAssertEqual(rows, 1)
        XCTAssertEqual(cell.textLabel?.text, "Пока нет пройденных тестов")
    }
    
    func testHistorySortedByNewestDate() {
        // GIVEN
        let oldResult = TestResult(
            testName: "Old Test",
            score: 5,
            date: Date(timeIntervalSince1970: 1000),
            status: "Old"
        )
        
        let newResult = TestResult(
            testName: "New Test",
            score: 20,
            date: Date(timeIntervalSince1970: 5000),
            status: "New"
        )
        
        saveMockHistory([oldResult, newResult])
        
        // WHEN
        let vc = makeViewController()
        let tableView = extractTableView(from: vc)!
        
        let cell = vc.tableView(
            tableView,
            cellForRowAt: IndexPath(row: 0, section: 0)
        ) as! TestHistoryCell
        
        // THEN
        XCTAssertNotNil(cell)
        
        // Проверяем, что первой идет новая запись
        // Через Mirror, так как labels private
        let mirror = Mirror(reflecting: cell)
        
        let testNameLabel = mirror.children.first {
            $0.label == "testNameLabel"
        }?.value as? UILabel
        
        XCTAssertEqual(testNameLabel?.text, "New Test")
    }
    
    func testDeleteHistoryItem() {
        // GIVEN
        let result1 = TestResult(
            testName: "Test 1",
            score: 10,
            date: Date(),
            status: "OK"
        )
        
        let result2 = TestResult(
            testName: "Test 2",
            score: 20,
            date: Date(),
            status: "OK"
        )
        
        saveMockHistory([result1, result2])
        
        // WHEN
        var savedHistory: [TestResult] = []
        
        if let data = UserDefaults.standard.data(forKey: "testHistory"),
           let decoded = try? JSONDecoder().decode([TestResult].self, from: data) {
            savedHistory = decoded
        }
        
        savedHistory.remove(at: 0)
        
        let encoded = try! JSONEncoder().encode(savedHistory)
        UserDefaults.standard.set(encoded, forKey: "testHistory")
        
        let vc = makeViewController()
        let tableView = extractTableView(from: vc)!
        
        // THEN
        XCTAssertEqual(vc.tableView(tableView, numberOfRowsInSection: 0), 1)
    }
}
