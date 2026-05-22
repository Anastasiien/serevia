//
//  MeditationTests.swift
//  sereviaTests
//
//  Created by Анастасия Бердюгина on 22.05.26.
//

import XCTest
@testable import serevia

final class MeditationTests: XCTestCase {

    private let favKey = "meditation_favorites"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: favKey)
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: favKey)
    }

    // Пустое избранное при первом запуске
    func testEmptyFavoritesOnFirstLaunch() {
        let loaded = UserDefaults.standard.stringArray(forKey: favKey) ?? []
        XCTAssertTrue(loaded.isEmpty, "При первом запуске избранное должно быть пустым")
    }

    // Медитация добавляется в избранное
    func testAddToFavorites() {
        var favorites = Set(UserDefaults.standard.stringArray(forKey: favKey) ?? [])
        favorites.insert("Дыхание покоя")
        UserDefaults.standard.set(Array(favorites), forKey: favKey)

        let loaded = UserDefaults.standard.stringArray(forKey: favKey) ?? []
        XCTAssertTrue(loaded.contains("Дыхание покоя"))
    }

    // Несколько медитаций в избранном
    func testMultipleFavorites() {
        var favorites = Set(UserDefaults.standard.stringArray(forKey: favKey) ?? [])
        favorites.insert("Дыхание покоя")
        favorites.insert("Мягкое засыпание")
        favorites.insert("Сила внимания")
        UserDefaults.standard.set(Array(favorites), forKey: favKey)

        let loaded = UserDefaults.standard.stringArray(forKey: favKey) ?? []
        XCTAssertEqual(loaded.count, 3)
    }

    // Медитация удаляется из избранного
    func testRemoveFromFavorites() {
        var favorites: Set<String> = ["Дыхание покоя", "Тепло и свет"]
        UserDefaults.standard.set(Array(favorites), forKey: favKey)

        favorites.remove("Дыхание покоя")
        UserDefaults.standard.set(Array(favorites), forKey: favKey)

        let loaded = UserDefaults.standard.stringArray(forKey: favKey) ?? []
        XCTAssertFalse(loaded.contains("Дыхание покоя"))
        XCTAssertTrue(loaded.contains("Тепло и свет"))
    }

    // Одна и та же медитация не дублируется в избранном
    func testNoDuplicatesInFavorites() {
        var favorites = Set(UserDefaults.standard.stringArray(forKey: favKey) ?? [])
        favorites.insert("Дыхание покоя")
        favorites.insert("Дыхание покоя")
        UserDefaults.standard.set(Array(favorites), forKey: favKey)

        let loaded = UserDefaults.standard.stringArray(forKey: favKey) ?? []
        let unique = Set(loaded)
        XCTAssertEqual(loaded.count, unique.count, "Дубликатов не должно быть")
    }

    // Избранное сохраняется между сессиями
    func testFavoritesPersistence() {
        UserDefaults.standard.set(["Покой и тишина", "Сон природы"], forKey: favKey)

        let loaded = Set(UserDefaults.standard.stringArray(forKey: favKey) ?? [])
        XCTAssertTrue(loaded.contains("Покой и тишина"))
        XCTAssertTrue(loaded.contains("Сон природы"))
        XCTAssertEqual(loaded.count, 2)
    }
}
