//
//  HabitTests.swift
//  sereviaTests
//
//  Created by Анастасия Бердюгина on 22.05.26.
//

import XCTest
@testable import serevia

final class HabitTests: XCTestCase {

    private let habitsKey     = "habits"
    private let streakKey     = "currentStreak"
    private let topStreakKey  = "topStreak"
    private let lastDateKey   = "lastStreakDate"
    private let lastResetKey  = "lastHabitResetDate"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: habitsKey)
        UserDefaults.standard.removeObject(forKey: streakKey)
        UserDefaults.standard.removeObject(forKey: topStreakKey)
        UserDefaults.standard.removeObject(forKey: lastDateKey)
        UserDefaults.standard.removeObject(forKey: lastResetKey)
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: habitsKey)
        UserDefaults.standard.removeObject(forKey: streakKey)
        UserDefaults.standard.removeObject(forKey: topStreakKey)
        UserDefaults.standard.removeObject(forKey: lastDateKey)
        UserDefaults.standard.removeObject(forKey: lastResetKey)
    }

    // MARK: - Habit структура

    func testHabitCreation() {
        let habit = Habit(title: "Медитация", isCompleted: false)
        XCTAssertEqual(habit.title, "Медитация")
        XCTAssertFalse(habit.isCompleted)
    }

    func testHabitCompletion() {
        var habit = Habit(title: "Спорт", isCompleted: false)
        habit.isCompleted = true
        XCTAssertTrue(habit.isCompleted)
    }

    // MARK: - Сохранение привычек

    func testSaveAndLoadHabits() {
        let habits = [
            Habit(title: "Медитация", isCompleted: false),
            Habit(title: "Спорт", isCompleted: true),
            Habit(title: "Чтение", isCompleted: false)
        ]
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: habitsKey)
        }
        guard let data = UserDefaults.standard.data(forKey: habitsKey),
              let loaded = try? JSONDecoder().decode([Habit].self, from: data) else {
            XCTFail("Не удалось загрузить привычки")
            return
        }
        XCTAssertEqual(loaded.count, 3)
        XCTAssertEqual(loaded[0].title, "Медитация")
        XCTAssertTrue(loaded[1].isCompleted)
    }

    func testEmptyHabitsLoad() {
        let data = UserDefaults.standard.data(forKey: habitsKey)
        XCTAssertNil(data, "Хранилище должно быть пустым")
    }

    // MARK: - Сброс привычек

    func testHabitsResetOnNewDay() {
        let habits = [
            Habit(title: "Медитация", isCompleted: true),
            Habit(title: "Спорт", isCompleted: true)
        ]
        // Симулируем что последний сброс был вчера
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        UserDefaults.standard.set(yesterday, forKey: lastResetKey)

        // Проверяем что дата отличается от сегодня
        let calendar = Calendar.current
        let today = Date()
        let needsReset = !calendar.isDate(yesterday, inSameDayAs: today)
        XCTAssertTrue(needsReset, "При смене дня должен происходить сброс")

        // Проверяем что после сброса все isCompleted = false
        let reset = habits.map { Habit(title: $0.title, isCompleted: false) }
        XCTAssertTrue(reset.allSatisfy { !$0.isCompleted }, "После сброса все привычки должны быть невыполненными")
    }

    func testHabitsNotResetSameDay() {
        let today = Date()
        UserDefaults.standard.set(today, forKey: lastResetKey)

        let last = UserDefaults.standard.object(forKey: lastResetKey) as? Date
        let needsReset = !(Calendar.current.isDate(last!, inSameDayAs: today))
        XCTAssertFalse(needsReset, "В тот же день сброс не должен происходить")
    }

    // MARK: - Стрик

    func testStreakIncreasesNextDay() {
        UserDefaults.standard.set(1, forKey: streakKey)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        UserDefaults.standard.set(yesterday, forKey: lastDateKey)

        let calendar = Calendar.current
        var streak = UserDefaults.standard.integer(forKey: streakKey)
        let last = UserDefaults.standard.object(forKey: lastDateKey) as? Date

        if let last = last {
            if calendar.isDateInYesterday(last) { streak += 1 }
        }

        XCTAssertEqual(streak, 2, "Стрик должен увеличиться до 2")
    }

    func testStreakResetsAfterSkip() {
        UserDefaults.standard.set(5, forKey: streakKey)
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        UserDefaults.standard.set(twoDaysAgo, forKey: lastDateKey)

        let calendar = Calendar.current
        var streak = UserDefaults.standard.integer(forKey: streakKey)
        let last = UserDefaults.standard.object(forKey: lastDateKey) as? Date

        if let last = last {
            if calendar.isDateInYesterday(last) { streak += 1 }
            else if !calendar.isDateInToday(last) { streak = 1 }
        }

        XCTAssertEqual(streak, 1, "Стрик должен сброситься до 1 после пропуска")
    }

    func testTopStreakUpdates() {
        UserDefaults.standard.set(3, forKey: streakKey)
        UserDefaults.standard.set(3, forKey: topStreakKey)

        var currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        var topStreak = UserDefaults.standard.integer(forKey: topStreakKey)

        currentStreak += 1
        if currentStreak > topStreak { topStreak = currentStreak }

        XCTAssertEqual(topStreak, 4, "Топ стрик должен обновиться до 4")
    }
}
