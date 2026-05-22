//
//  Datetests.swift
//  sereviaTests
//
//  Created by Анастасия Бердюгина on 23.05.26.
//

import XCTest
@testable import serevia

final class DateTests: XCTestCase {

    // Две даты в один день определяются корректно
    func testSameDayDetection() {
        let date1 = Date()
        let date2 = Date().addingTimeInterval(3600) // +1 час
        let isSameDay = Calendar.current.isDate(date1, inSameDayAs: date2)
        XCTAssertTrue(isSameDay, "Две даты в одном дне должны определяться как один день")
    }

    // Вчерашняя дата определяется как вчера
    func testYesterdayDetection() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertTrue(Calendar.current.isDateInYesterday(yesterday), "Вчерашняя дата должна определяться как вчера")
    }

    // Дата двухдневной давности не является вчерашней
    func testTwoDaysAgoIsNotYesterday() {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        XCTAssertFalse(Calendar.current.isDateInYesterday(twoDaysAgo), "Дата двухдневной давности не должна быть вчерашней")
    }

    // Сегодняшняя дата не является вчерашней
    func testTodayIsNotYesterday() {
        XCTAssertFalse(Calendar.current.isDateInYesterday(Date()), "Сегодня не должно быть вчерашним")
    }

    // Разные дни не являются одним днём
    func testDifferentDaysNotSameDay() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        XCTAssertFalse(Calendar.current.isDate(today, inSameDayAs: tomorrow), "Разные дни не должны совпадать")
    }
}
