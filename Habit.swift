//
//  Habit.swift
//  serevia
//
//  Created by Анастасия Бердюгина on 03.05.26.
//

import Foundation

struct Habit: Codable {
    var title: String
    var isCompleted: Bool
    var currentStreak: Int
}

// Константа для уведомления
extension Notification.Name {
    static let wishMapUpdated = Notification.Name("wishMapUpdated")
}
