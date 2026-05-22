//
//  DiaryStorageTests.swift
//  sereviaTests
//
//  Created by Анастасия Бердюгина on 22.05.26.
//

import XCTest
@testable import serevia

final class DiaryStorageTests: XCTestCase {

    private let testKey = "diary_entries"

    override func setUp() {
        super.setUp()
        // Очищаем перед каждым тестом
        UserDefaults.standard.removeObject(forKey: testKey)
    }

    override func tearDown() {
        super.tearDown()
        // Очищаем после каждого теста
        UserDefaults.standard.removeObject(forKey: testKey)
    }

    // Пустое хранилище возвращает пустой массив
    func testLoadEmptyEntries() {
        let entries = DiaryStorage.shared.loadEntries()
        XCTAssertTrue(entries.isEmpty, "Новое хранилище должно быть пустым")
    }

    // Запись сохраняется и загружается
    func testSaveAndLoadEntry() {
        let entry = DiaryEntry(
            date: Date(),
            text: "Тестовая запись",
            mood: "😊",
            imageData: nil,
            tags: ["тест"],
            color: nil
        )
        DiaryStorage.shared.save(entry: entry)
        let entries = DiaryStorage.shared.loadEntries()
        XCTAssertEqual(entries.count, 1, "Должна быть одна запись")
        XCTAssertEqual(entries.first?.text, "Тестовая запись")
        XCTAssertEqual(entries.first?.mood, "😊")
    }

    // Новая запись вставляется в начало
    func testNewEntryInsertedFirst() {
        let first = DiaryEntry(date: Date(), text: "Первая", mood: "😊", imageData: nil, tags: [], color: nil)
        let second = DiaryEntry(date: Date().addingTimeInterval(1), text: "Вторая", mood: "😢", imageData: nil, tags: [], color: nil)

        DiaryStorage.shared.save(entry: first)
        DiaryStorage.shared.save(entry: second)

        let entries = DiaryStorage.shared.loadEntries()
        XCTAssertEqual(entries.first?.text, "Вторая", "Последняя добавленная должна быть первой")
    }

    // Удаление записи работает
    func testDeleteEntry() {
        let entry = DiaryEntry(date: Date(), text: "Удалить меня", mood: "😐", imageData: nil, tags: [], color: nil)
        DiaryStorage.shared.save(entry: entry)
        DiaryStorage.shared.delete(entry: entry)

        let entries = DiaryStorage.shared.loadEntries()
        XCTAssertTrue(entries.isEmpty, "После удаления хранилище должно быть пустым")
    }

    // Удаление одной из нескольких записей
    func testDeleteOneOfMultiple() {
        let entry1 = DiaryEntry(date: Date(), text: "Первая", mood: "😊", imageData: nil, tags: [], color: nil)
        let entry2 = DiaryEntry(date: Date().addingTimeInterval(1), text: "Вторая", mood: "😢", imageData: nil, tags: [], color: nil)

        DiaryStorage.shared.save(entry: entry1)
        DiaryStorage.shared.save(entry: entry2)
        DiaryStorage.shared.delete(entry: entry1)

        let entries = DiaryStorage.shared.loadEntries()
        XCTAssertEqual(entries.count, 1, "Должна остаться одна запись")
        XCTAssertEqual(entries.first?.text, "Вторая")
    }

    // Теги сохраняются корректно
    func testTagsSaved() {
        let entry = DiaryEntry(date: Date(), text: "", mood: "😊", imageData: nil, tags: ["работа", "спорт", "настроение"], color: nil)
        DiaryStorage.shared.save(entry: entry)

        let loaded = DiaryStorage.shared.loadEntries().first
        XCTAssertEqual(loaded?.tags.count, 3)
        XCTAssertTrue(loaded?.tags.contains("работа") ?? false)
    }

    // Цвет сохраняется корректно
    func testColorSaved() {
        let entry = DiaryEntry(date: Date(), text: "", mood: "😊", imageData: nil, tags: [], color: "#FF5733")
        DiaryStorage.shared.save(entry: entry)

        let loaded = DiaryStorage.shared.loadEntries().first
        XCTAssertEqual(loaded?.color, "#FF5733")
    }
}
