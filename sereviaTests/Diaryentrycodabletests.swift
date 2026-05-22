//
//  Diaryentrycodabletests.swift
//  sereviaTests
//
//  Created by Анастасия Бердюгина on 23.05.26.
//

import XCTest
@testable import serevia

final class DiaryEntryCodableTests: XCTestCase {

    // DiaryEntry корректно кодируется в JSON
    func testDiaryEntryCodable() {
        let entry = DiaryEntry(
            date: Date(timeIntervalSince1970: 1000000),
            text: "Тестовая запись",
            mood: "😊",
            imageData: nil,
            tags: ["работа", "спорт"],
            color: "#FF5733"
        )
        guard let data = try? JSONEncoder().encode(entry) else {
            XCTFail("Не удалось закодировать DiaryEntry")
            return
        }
        XCTAssertFalse(data.isEmpty)
    }

    // DiaryEntry корректно декодируется из JSON
    func testDiaryEntryDecodable() {
        let original = DiaryEntry(
            date: Date(timeIntervalSince1970: 1000000),
            text: "Оригинальная запись",
            mood: "😢",
            imageData: nil,
            tags: ["тест"],
            color: nil
        )
        guard let data = try? JSONEncoder().encode(original),
              let decoded = try? JSONDecoder().decode(DiaryEntry.self, from: data) else {
            XCTFail("Не удалось декодировать DiaryEntry")
            return
        }
        XCTAssertEqual(decoded.text, original.text)
        XCTAssertEqual(decoded.mood, original.mood)
        XCTAssertEqual(decoded.tags, original.tags)
        XCTAssertEqual(decoded.color, original.color)
    }

    // DiaryEntry с imageData корректно кодируется и декодируется
    func testDiaryEntryWithImageData() {
        let imageData = "тестовые данные".data(using: .utf8)
        let entry = DiaryEntry(
            date: Date(),
            text: "С фото",
            mood: "😊",
            imageData: imageData,
            tags: [],
            color: nil
        )
        guard let data = try? JSONEncoder().encode(entry),
              let decoded = try? JSONDecoder().decode(DiaryEntry.self, from: data) else {
            XCTFail("Не удалось кодировать/декодировать запись с imageData")
            return
        }
        XCTAssertNotNil(decoded.imageData)
        XCTAssertEqual(decoded.imageData, imageData)
    }
}
