//
//  MeditationTests.swift
//  sereviaTests
//
//  Created by Анастасия Бердюгина on 22.05.26.
//

import XCTest
@testable import serevia

// MARK: - Граничные случаи

final class EdgeCaseTests: XCTestCase {

    private let habitsKey = "habits"
    private let diaryKey  = "diary_entries"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: habitsKey)
        UserDefaults.standard.removeObject(forKey: diaryKey)
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: habitsKey)
        UserDefaults.standard.removeObject(forKey: diaryKey)
    }

    // Привычка с пустым названием создаётся без ошибок
    func testHabitWithEmptyTitle() {
        let habit = Habit(title: "", isCompleted: false)
        XCTAssertEqual(habit.title, "")
        XCTAssertFalse(habit.isCompleted)
    }

    // Привычка с пустым названием сохраняется
    func testHabitWithEmptyTitleSaves() {
        let habits = [Habit(title: "", isCompleted: false)]
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: habitsKey)
        }
        guard let data = UserDefaults.standard.data(forKey: habitsKey),
              let loaded = try? JSONDecoder().decode([Habit].self, from: data) else {
            XCTFail("Не удалось загрузить")
            return
        }
        XCTAssertEqual(loaded.first?.title, "")
    }

    // Удаление несуществующей записи дневника не ломает хранилище
    func testDeleteNonExistentDiaryEntry() {
        let existing = DiaryEntry(date: Date(), text: "Существующая", mood: "😊", imageData: nil, tags: [], color: nil)
        DiaryStorage.shared.save(entry: existing)

        let nonExistent = DiaryEntry(date: Date().addingTimeInterval(9999), text: "Не существует", mood: "😢", imageData: nil, tags: [], color: nil)
        DiaryStorage.shared.delete(entry: nonExistent)

        let entries = DiaryStorage.shared.loadEntries()
        XCTAssertEqual(entries.count, 1, "Существующая запись должна остаться")
    }

    // Запись дневника без тегов сохраняется корректно
    func testDiaryEntryWithNoTags() {
        let entry = DiaryEntry(date: Date(), text: "Без тегов", mood: "😐", imageData: nil, tags: [], color: nil)
        DiaryStorage.shared.save(entry: entry)
        let loaded = DiaryStorage.shared.loadEntries().first
        XCTAssertTrue(loaded?.tags.isEmpty ?? false)
    }

    // Запись дневника без текста сохраняется корректно
    func testDiaryEntryWithEmptyText() {
        let entry = DiaryEntry(date: Date(), text: "", mood: "😊", imageData: nil, tags: [], color: nil)
        DiaryStorage.shared.save(entry: entry)
        let loaded = DiaryStorage.shared.loadEntries().first
        XCTAssertEqual(loaded?.text, "")
    }

    // Множественное сохранение одной привычки не дублирует
    func testSavingMultipleHabits() {
        let habits = [
            Habit(title: "Спорт", isCompleted: false),
            Habit(title: "Спорт", isCompleted: true)
        ]
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: habitsKey)
        }
        guard let data = UserDefaults.standard.data(forKey: habitsKey),
              let loaded = try? JSONDecoder().decode([Habit].self, from: data) else {
            XCTFail("Не удалось загрузить")
            return
        }
        XCTAssertEqual(loaded.count, 2, "Должны сохраниться обе записи")
    }
}
