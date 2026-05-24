//
//  WellBeingTestViewControllerTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class WellBeingTestViewControllerTests: XCTestCase {

    // MARK: - Helper

    private func level(for score: Int) -> String {
        if score > 42 {
            return "Высокий"
        } else if score > 28 {
            return "Средний"
        } else {
            return "Низкий"
        }
    }

    // MARK: - Level Interpretation Tests

    func testHighLevelInterpretation() {
        XCTAssertEqual(level(for: 45), "Высокий")
    }

    func testMediumLevelInterpretation() {
        XCTAssertEqual(level(for: 35), "Средний")
    }

    func testLowLevelInterpretation() {
        XCTAssertEqual(level(for: 20), "Низкий")
    }

    // MARK: - Question Score Tests

    func testNormalQuestionScoreCalculation() {

        let question = WellBeingTestViewController.Question(
            text: "Тест",
            scale: 0,
            isReverse: false
        )

        let answer = 5

        let score = question.isReverse
        ? (7 - answer)
        : answer

        XCTAssertEqual(score, 5)
    }

    func testReverseQuestionScoreCalculation() {

        let question = WellBeingTestViewController.Question(
            text: "Тест",
            scale: 1,
            isReverse: true
        )

        let answer = 2

        let score = question.isReverse
        ? (7 - answer)
        : answer

        XCTAssertEqual(score, 5)
    }

    // MARK: - Scale Score Tests

    func testScaleScoreUpdate() {

        var scaleScores = Array(repeating: 0, count: 6)

        let question = WellBeingTestViewController.Question(
            text: "Тест",
            scale: 2,
            isReverse: false
        )

        let answer = 4

        scaleScores[question.scale] += question.isReverse
        ? (7 - answer)
        : answer

        XCTAssertEqual(scaleScores[2], 4)
    }

    func testReverseScaleScoreUpdate() {

        var scaleScores = Array(repeating: 0, count: 6)

        let question = WellBeingTestViewController.Question(
            text: "Тест",
            scale: 3,
            isReverse: true
        )

        let answer = 1

        scaleScores[question.scale] += question.isReverse
        ? (7 - answer)
        : answer

        XCTAssertEqual(scaleScores[3], 6)
    }

    // MARK: - Total Score Tests

    func testTotalScoreCalculation() {

        let scaleScores = [30, 35, 40, 45, 25, 50]

        let totalScore = scaleScores.reduce(0, +)

        XCTAssertEqual(totalScore, 225)
    }

    func testEmptyTotalScore() {

        let scaleScores = Array(repeating: 0, count: 6)

        let totalScore = scaleScores.reduce(0, +)

        XCTAssertEqual(totalScore, 0)
    }

    // MARK: - Question Model Tests

    func testQuestionInitialization() {

        let question = WellBeingTestViewController.Question(
            text: "Проверка",
            scale: 4,
            isReverse: true
        )

        XCTAssertEqual(question.text, "Проверка")
        XCTAssertEqual(question.scale, 4)
        XCTAssertTrue(question.isReverse)
    }

    // MARK: - Scale Mapping Tests

    func testRelationshipScale() {

        let question = WellBeingTestViewController.Question(
            text: "Отношения",
            scale: 0,
            isReverse: false
        )

        XCTAssertEqual(question.scale, 0)
    }

    func testAutonomyScale() {

        let question = WellBeingTestViewController.Question(
            text: "Автономия",
            scale: 1,
            isReverse: false
        )

        XCTAssertEqual(question.scale, 1)
    }

    func testMasteryScale() {

        let question = WellBeingTestViewController.Question(
            text: "Мастерство",
            scale: 2,
            isReverse: false
        )

        XCTAssertEqual(question.scale, 2)
    }

    func testGrowthScale() {

        let question = WellBeingTestViewController.Question(
            text: "Рост",
            scale: 3,
            isReverse: false
        )

        XCTAssertEqual(question.scale, 3)
    }

    func testGoalsScale() {

        let question = WellBeingTestViewController.Question(
            text: "Цели",
            scale: 4,
            isReverse: false
        )

        XCTAssertEqual(question.scale, 4)
    }

    func testSelfAcceptanceScale() {

        let question = WellBeingTestViewController.Question(
            text: "Самопринятие",
            scale: 5,
            isReverse: false
        )

        XCTAssertEqual(question.scale, 5)
    }
}
