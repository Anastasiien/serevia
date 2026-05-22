//
//  Chatstoragetests.swift
//  sereviaTests
//
//  Created by Анастасия Бердюгина on 23.05.26.
//

import XCTest
@testable import serevia

final class ChatStorageTests: XCTestCase {

    private let key = "chat_sessions"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: key)
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: key)
    }

    // Пустое хранилище при первом запуске
    func testEmptySessionsOnFirstLaunch() {
        let sessions = ChatStorage.shared.loadSessions()
        XCTAssertTrue(sessions.isEmpty, "При первом запуске сессий не должно быть")
    }

    // Сессия сохраняется и загружается
    func testSaveAndLoadSession() {
        let session = ChatSession(
            id: UUID().uuidString,
            title: "Тестовая сессия",
            date: Date(),
            messages: []
        )
        ChatStorage.shared.saveSessions([session])
        let loaded = ChatStorage.shared.loadSessions()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.title, "Тестовая сессия")
    }

    // Несколько сессий сохраняются корректно
    func testSaveMultipleSessions() {
        let sessions = [
            ChatSession(id: UUID().uuidString, title: "Сессия 1", date: Date(), messages: []),
            ChatSession(id: UUID().uuidString, title: "Сессия 2", date: Date(), messages: []),
            ChatSession(id: UUID().uuidString, title: "Сессия 3", date: Date(), messages: [])
        ]
        ChatStorage.shared.saveSessions(sessions)
        let loaded = ChatStorage.shared.loadSessions()
        XCTAssertEqual(loaded.count, 3)
    }

    // Удаление сессии
    func testDeleteSession() {
        let session = ChatSession(id: "delete-me", title: "Удалить", date: Date(), messages: [])
        ChatStorage.shared.saveSessions([session])

        var sessions = ChatStorage.shared.loadSessions()
        sessions.removeAll { $0.id == "delete-me" }
        ChatStorage.shared.saveSessions(sessions)

        let loaded = ChatStorage.shared.loadSessions()
        XCTAssertTrue(loaded.isEmpty)
    }

    // Переименование сессии
    func testRenameSession() {
        var session = ChatSession(id: "rename-me", title: "Старое название", date: Date(), messages: [])
        ChatStorage.shared.saveSessions([session])

        var sessions = ChatStorage.shared.loadSessions()
        if let idx = sessions.firstIndex(where: { $0.id == "rename-me" }) {
            sessions[idx].title = "Новое название"
        }
        ChatStorage.shared.saveSessions(sessions)

        let loaded = ChatStorage.shared.loadSessions()
        XCTAssertEqual(loaded.first?.title, "Новое название")
    }

    // Сообщения сохраняются внутри сессии
    func testMessagesInSession() {
        let messages = [
            StoredMessage(text: "Привет", isUser: true),
            StoredMessage(text: "Здравствуй!", isUser: false)
        ]
        let session = ChatSession(id: UUID().uuidString, title: "С сообщениями", date: Date(), messages: messages)
        ChatStorage.shared.saveSessions([session])

        let loaded = ChatStorage.shared.loadSessions().first
        XCTAssertEqual(loaded?.messages.count, 2)
        XCTAssertEqual(loaded?.messages.first?.text, "Привет")
        XCTAssertTrue(loaded?.messages.first?.isUser ?? false)
    }
}
