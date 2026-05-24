//
//  TestResultTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class TestResultTests: XCTestCase {
    
    // MARK: - testTestHistoryCodable()
    
    func testTestHistoryCodable() throws {
        // GIVEN
        let result = TestResult(
            testName: "Beck Depression Test",
            score: 18,
            date: Date(),
            status: "Средняя депрессия"
        )
        
        // WHEN
        let encoded = try JSONEncoder().encode(result)
        let decoded = try JSONDecoder().decode(TestResult.self, from: encoded)
        
        // THEN
        XCTAssertEqual(decoded.testName, result.testName)
        XCTAssertEqual(decoded.score, result.score)
        XCTAssertEqual(decoded.status, result.status)
    }
    
    // MARK: - testEncodeDecodeHistory()
    
    func testEncodeDecodeHistory() throws {
        // GIVEN
        let history = [
            TestResult(
                testName: "BAI",
                score: 12,
                date: Date(),
                status: "Низкая тревожность"
            ),
            TestResult(
                testName: "MAAS",
                score: 4.7,
                date: Date(),
                status: "Высокая осознанность"
            )
        ]
        
        // WHEN
        let encoded = try JSONEncoder().encode(history)
        let decoded = try JSONDecoder().decode([TestResult].self, from: encoded)
        
        // THEN
        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].testName, "BAI")
        XCTAssertEqual(decoded[1].testName, "MAAS")
        XCTAssertEqual(decoded[1].score, 4.7)
    }
    
    // MARK: - testHistoryPropertiesStored()
    
    func testHistoryPropertiesStored() {
        // GIVEN
        let date = Date(timeIntervalSince1970: 1715000000)
        
        let result = TestResult(
            testName: "Mindfulness Test",
            score: 3.8,
            date: date,
            status: "Средний уровень"
        )
        
        // THEN
        XCTAssertEqual(result.testName, "Mindfulness Test")
        XCTAssertEqual(result.score, 3.8)
        XCTAssertEqual(result.date, date)
        XCTAssertEqual(result.status, "Средний уровень")
    }
    
    // MARK: - testFormattedDateNotEmpty()
    
    func testFormattedDateNotEmpty() {
        // GIVEN
        let result = TestResult(
            testName: "Test",
            score: 10,
            date: Date(),
            status: "OK"
        )
        
        // WHEN
        let formattedDate = result.formattedDate
        
        // THEN
        XCTAssertFalse(formattedDate.isEmpty)
    }
    
    // MARK: - testFormattedDateMatchesExpectedFormat()
    
    func testFormattedDateMatchesExpectedFormat() {
        // GIVEN
        let date = Date(timeIntervalSince1970: 1715000000)
        
        let result = TestResult(
            testName: "Test",
            score: 10,
            date: date,
            status: "OK"
        )
        
        // WHEN
        let formattedDate = result.formattedDate
        
        // THEN
        XCTAssertEqual(formattedDate.count, 16)
        XCTAssertTrue(formattedDate.contains("."))
        XCTAssertTrue(formattedDate.contains(":"))
    }
    
    // MARK: - testUUIDGenerated()
    
    func testUUIDGenerated() {
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
        
        // THEN
        XCTAssertNotEqual(result1.id, result2.id)
    }
    
    // MARK: - testDoubleScoreSupportsDecimalValues()
    
    func testDoubleScoreSupportsDecimalValues() {
        // GIVEN
        let result = TestResult(
            testName: "MAAS",
            score: 4.6,
            date: Date(),
            status: "Высокая осознанность"
        )
        
        // THEN
        XCTAssertEqual(result.score, 4.6)
    }
    
    // MARK: - testDoubleScoreSupportsIntegerValues()
    
    func testDoubleScoreSupportsIntegerValues() {
        // GIVEN
        let result = TestResult(
            testName: "BDI",
            score: 21,
            date: Date(),
            status: "Умеренная депрессия"
        )
        
        // THEN
        XCTAssertEqual(result.score, 21)
    }
}
