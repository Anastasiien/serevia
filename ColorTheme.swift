//
//  ColorTheme.swift
//  Mindfulness
//
//  Created by Анастасия Бердюгина on 07.11.25.
//

import UIKit

struct AppColors {
    // Основная палитра: коричнево-бежевая
    static let background = UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0) // Бежевый фон
    static let primary = UIColor(red: 0.44, green: 0.33, blue: 0.25, alpha: 1.0)   // Основной коричневый
    static let secondary = UIColor(red: 0.67, green: 0.55, blue: 0.42, alpha: 1.0) // Светло-коричневый для выделений
    static let accent = UIColor(red: 0.82, green: 0.71, blue: 0.55, alpha: 1.0)    // Акцентный бежево-коричневый
    static let text = UIColor(red: 0.25, green: 0.20, blue: 0.15, alpha: 1.0)      // Темно-коричневый для текста
    static let lightText = UIColor(red: 0.44, green: 0.33, blue: 0.25, alpha: 0.7) // Светлый текст
    static let card = UIColor(red: 0.99, green: 0.985, blue: 0.98, alpha: 1.0)      // Цвет карточек/секций
    static let border = UIColor(red: 0.82, green: 0.71, blue: 0.55, alpha: 0.3)    // Цвет границ
    static let sectionBackground = UIColor(red: 0.90, green: 0.85, blue: 0.78, alpha: 1.0) // Более коричневый для разделов
}
