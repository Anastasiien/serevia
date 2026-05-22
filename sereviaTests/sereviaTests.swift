//
//  sereviaTests.swift
//  sereviaTests
//
//  Created by Анастасия Бердюгина on 22.05.26.
//

import XCTest
@testable import serevia

final class AIClassifierTests: XCTestCase {

    // MARK: - Словарные тесты (не требуют CoreML)

    func testAnxietyKeywords() {
        let inputs = ["у меня тревога", "меня накрывает паника", "я боюсь этого"]
        for input in inputs {
            XCTAssertEqual(classifyByKeywords(input), "anxiety", "Ожидалась тревога для: \(input)")
        }
    }

    func testSadnessKeywords() {
        let inputs = ["мне так грустно", "хочется плакать", "всё плохо"]
        for input in inputs {
            XCTAssertEqual(classifyByKeywords(input), "sadness", "Ожидалась грусть для: \(input)")
        }
    }

    func testFatigueKeywords() {
        let inputs = ["я устала", "совсем нет сил", "всё надоело"]
        for input in inputs {
            XCTAssertEqual(classifyByKeywords(input), "fatigue", "Ожидалась усталость для: \(input)")
        }
    }

    func testStressKeywords() {
        let inputs = ["дедлайн завтра", "не успеваю", "всё навалилось"]
        for input in inputs {
            XCTAssertEqual(classifyByKeywords(input), "stress", "Ожидался стресс для: \(input)")
        }
    }

    func testSleepKeywords() {
        let inputs = ["не могу уснуть", "бессонница замучила", "ночь не сплю"]
        for input in inputs {
            XCTAssertEqual(classifyByKeywords(input), "sleep", "Ожидалась категория сна для: \(input)")
        }
    }

    func testPositiveKeywords() {
        let inputs = ["сегодня отлично", "я счастлива", "всё хорошо"]
        for input in inputs {
            XCTAssertEqual(classifyByKeywords(input), "positive", "Ожидался позитив для: \(input)")
        }
    }

    func testAngerKeywords() {
        let inputs = ["я так злюсь", "это бесит", "достало всё"]
        for input in inputs {
            XCTAssertEqual(classifyByKeywords(input), "anger", "Ожидалась злость для: \(input)")
        }
    }

    func testLonelinessKeywords() {
        let inputs = ["я совсем одна", "никто не понимает", "не с кем поговорить"]
        for input in inputs {
            XCTAssertEqual(classifyByKeywords(input), "loneliness", "Ожидалось одиночество для: \(input)")
        }
    }

    // MARK: - Нейтральный фильтр

    func testNeutralPhrases() {
        let neutralInputs = ["спасибо", "окей", "понятно", "да", "нет"]
        for input in neutralInputs {
            XCTAssertEqual(classifyByKeywords(input), "neutral", "Ожидался нейтральный для: \(input)")
        }
    }

    // MARK: - Вспомогательный метод (дублирует логику из AIViewController)

    private func classifyByKeywords(_ input: String) -> String {
        let lowered = input.lowercased()

        let neutralPhrases = ["спасибо", "благодарю", "понятно", "окей", "ок",
                              "да", "нет", "ага", "угу"]
        if neutralPhrases.contains(where: { lowered.trimmingCharacters(in: .punctuationCharacters) == $0 }) {
            return "neutral"
        }

        let keywords: [String: [String]] = [
            "anxiety":    ["тревог", "паник", "страх", "боюсь", "страшно", "накрывает"],
            "sadness":    ["грустн", "плачу", "всё плохо", "хочется плакать", "мне плохо"],
            "sleep":      ["не сплю", "бессонниц", "не могу уснуть", "ночь не сплю"],
            "fatigue":    ["устал", "устала", "нет сил", "всё надоело", "сил нет"],
            "anger":      ["злюсь", "бесит", "достало", "злость", "ярость"],
            "stress":     ["дедлайн", "не успеваю", "всё навалилось", "стресс"],
            "loneliness": ["одна", "одинок", "не с кем", "никто не понимает"],
            "positive":   ["хорошо", "отлично", "счастлив", "счастлива", "всё хорошо"]
        ]

        var scores: [String: Int] = [:]
        for (label, words) in keywords {
            let count = words.filter { lowered.contains($0) }.count
            if count > 0 { scores[label] = count }
        }

        return scores.max(by: { $0.value < $1.value })?.key ?? "unknown"
    }
}
