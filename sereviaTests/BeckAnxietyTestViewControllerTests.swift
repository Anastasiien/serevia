//
//  BeckAnxietyTestViewControllerTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class BeckAnxietyTestViewControllerTests: XCTestCase {

    var sut: BeckAnxietyTestViewController!

    override func setUp() {
        super.setUp()

        sut = BeckAnxietyTestViewController()
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
            "Уровень тревожности"
        )
    }

    func testStartButtonExists() {

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        let containsStartButton = buttons.contains {
            $0.title(for: .normal) == "Начать тест"
        }

        XCTAssertTrue(containsStartButton)
    }

    // MARK: - Start Test

    func testStartTestShowsQuestions() {

        sut.perform(
            NSSelectorFromString("startTest")
        )

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        XCTAssertTrue(buttons.count >= 4)
    }

    // MARK: - Question Navigation

    func testQuestionNavigation() {

        sut.perform(
            NSSelectorFromString("startTest")
        )

        let initialMirror = Mirror(reflecting: sut!)

        let initialIndex = initialMirror.children.first {
            $0.label == "currentQuestionIndex"
        }?.value as? Int

        XCTAssertEqual(initialIndex, 0)

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        let answerButton = buttons.first {
            $0.tag == 1
        }

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

    func testAnxietyScoreCalculation() {

        sut.perform(
            NSSelectorFromString("startTest")
        )

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        let answerButton = buttons.first {
            $0.tag == 2
        }

        sut.perform(
            NSSelectorFromString("optionSelected:"),
            with: answerButton
        )

        let mirror = Mirror(reflecting: sut!)

        let totalScore = mirror.children.first {
            $0.label == "totalScore"
        }?.value as? Int

        XCTAssertEqual(totalScore, 2)
    }

    // MARK: - Result Generation

    func testResultGeneration() {

        let sut = BeckAnxietyTestViewController()

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = sut
        window.makeKeyAndVisible()

        sut.loadViewIfNeeded()
        sut.perform(#selector(BeckAnxietyTestViewController.startTest))

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.3))

        for _ in 0..<21 {

            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))

            let buttons = findSubviews(in: sut.view, ofType: UIButton.self)

            guard let answerButton = buttons.first(where: { $0.tag == 0 }) else {
                XCTFail("Кнопка ответа не найдена")
                return
            }

            sut.perform(
                #selector(BeckAnxietyTestViewController.optionSelected(_:)),
                with: answerButton
            )

            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))

        let alert = sut.presentedViewController as? UIAlertController

        XCTAssertNotNil(alert, "Alert не был показан")

        XCTAssertTrue(
            alert?.title?.contains("Результат") == true,
            "Неверный title алерта: \(alert?.title ?? "nil")"
        )
    }

    // MARK: - Score Interpretation

    func testInterpretLowScore() {

        let result = interpretScore(10)

        XCTAssertEqual(
            result.0,
            "Низкий уровень тревожности"
        )
    }

    func testInterpretMediumScore() {

        let result = interpretScore(30)

        XCTAssertEqual(
            result.0,
            "Средний уровень тревожности"
        )
    }

    func testInterpretHighScore() {

        let result = interpretScore(50)

        XCTAssertEqual(
            result.0,
            "Высокий уровень тревожности"
        )
    }
}

// MARK: - Helpers

extension BeckAnxietyTestViewControllerTests {

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
        _ score: Int
    ) -> (String, String) {

        switch score {

        case 0...21:
            return (
                "Низкий уровень тревожности",
                "Ваше состояние в пределах нормы."
            )

        case 22...35:
            return (
                "Средний уровень тревожности",
                "Умеренная тревожность."
            )

        case 36...63:
            return (
                "Высокий уровень тревожности",
                "Рекомендуется консультация."
            )

        default:
            return (
                "Результат",
                "Тест завершен."
            )
        }
    }
}
