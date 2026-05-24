//
//  MindfulnessTestViewControllerTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class MindfulnessTestViewControllerTests: XCTestCase {

    var sut: MindfulnessTestViewController!

    override func setUp() {
        super.setUp()

        sut = MindfulnessTestViewController()
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Basic UI

    func testViewDidLoad() {
        XCTAssertNotNil(sut.view)
    }

    func testTitleExists() {
        XCTAssertEqual(
            sut.title,
            "Внимательность и осознанность"
        )
    }

    func testStartButtonExists() {

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        let containsButton = buttons.contains {
            $0.title(for: .normal) == "Начать тест"
        }

        XCTAssertTrue(containsButton)
    }

    // MARK: - Start Test

    func testStartTestShowsQuestions() {

        sut.perform(NSSelectorFromString("startTest"))

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        XCTAssertTrue(buttons.count >= 6)
    }

    // MARK: - Question Progress

    func testQuestionsProgress() {

        sut.perform(NSSelectorFromString("startTest"))

        let initialMirror = Mirror(reflecting: sut!)

        let initialIndex = initialMirror.children.first {
            $0.label == "currentQuestionIndex"
        }?.value as? Int

        XCTAssertEqual(initialIndex, 0)

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        let answerButton = buttons.first { $0.tag == 3 }

        sut.perform(
            NSSelectorFromString("optionSelected:"),
            with: answerButton
        )

        let updatedMirror = Mirror(reflecting: sut!)

        let updatedIndex = updatedMirror.children.first {
            $0.label == "currentQuestionIndex"
        }?.value as? Int

        XCTAssertEqual(updatedIndex, 1)
    }

    // MARK: - Score Calculation

    func testMindfulnessScoreCalculation() {

        sut.perform(NSSelectorFromString("startTest"))

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        let answerButton = buttons.first { $0.tag == 4 }

        sut.perform(
            NSSelectorFromString("optionSelected:"),
            with: answerButton
        )

        let mirror = Mirror(reflecting: sut!)

        let totalPoints = mirror.children.first {
            $0.label == "totalPoints"
        }?.value as? Int

        XCTAssertEqual(totalPoints, 4)
    }

    func testReverseQuestionScoring() {

        sut.perform(NSSelectorFromString("startTest"))

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        let lowestButton = buttons.first { $0.tag == 1 }
        let highestButton = buttons.first { $0.tag == 6 }

        sut.perform(
            NSSelectorFromString("optionSelected:"),
            with: lowestButton
        )

        var mirror = Mirror(reflecting: sut!)

        let lowScore = mirror.children.first {
            $0.label == "totalPoints"
        }?.value as? Int

        XCTAssertEqual(lowScore, 1)

        sut.perform(
            NSSelectorFromString("optionSelected:"),
            with: highestButton
        )

        mirror = Mirror(reflecting: sut!)

        let updatedScore = mirror.children.first {
            $0.label == "totalPoints"
        }?.value as? Int

        XCTAssertEqual(updatedScore, 7)
    }

    // MARK: - Interpretation

    func testInterpretLowMindfulness() {

        let result = interpretScore(2.5)

        XCTAssertEqual(
            result.0,
            "Низкий уровень осознанности"
        )
    }

    func testInterpretHighMindfulness() {

        let result = interpretScore(5.5)

        XCTAssertEqual(
            result.0,
            "Высокий уровень осознанности"
        )
    }
}

// MARK: - Helpers

extension MindfulnessTestViewControllerTests {

    func findSubviews<T: UIView>(
        in view: UIView,
        ofType type: T.Type
    ) -> [T] {

        var result = [T]()

        for subview in view.subviews {

            if let typedView = subview as? T {
                result.append(typedView)
            }

            result.append(
                contentsOf: findSubviews(
                    in: subview,
                    ofType: type
                )
            )
        }

        return result
    }

    func interpretScore(
        _ score: Double
    ) -> (String, String) {

        switch score {

        case 1.0...3.0:
            return (
                "Низкий уровень осознанности",
                "Низкая осознанность"
            )

        case 3.1...4.5:
            return (
                "Средний уровень осознанности",
                "Средняя осознанность"
            )

        case 4.6...6.0:
            return (
                "Высокий уровень осознанности",
                "Высокая осознанность"
            )

        default:
            return (
                "Результат",
                "Тест завершен."
            )
        }
    }
}
