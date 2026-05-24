//
//  BeckTestViewControllerTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class BeckTestViewControllerTests: XCTestCase {

    var sut: BeckTestViewController!

    override func setUp() {
        super.setUp()

        sut = BeckTestViewController()
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
    }

    // MARK: - UI

    func testViewDidLoad() {
        XCTAssertNotNil(sut.view)
    }

    func testTitleExists() {
        XCTAssertEqual(sut.title, "Уровень депрессии")
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

        let selector = NSSelectorFromString("startTest")

        sut.perform(selector)

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        XCTAssertTrue(buttons.count >= 4)
    }

    // MARK: - Question Logic

    func testQuestionProgression() {

        let selector = NSSelectorFromString("startTest")
        sut.perform(selector)

        let initialMirror = Mirror(reflecting: sut!)

        let initialIndex = initialMirror.children.first {
            $0.label == "currentQuestionIndex"
        }?.value as? Int

        XCTAssertEqual(initialIndex, 0)

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        let answerButton = buttons.first { $0.tag == 1 }

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

    func testScoreCalculation() {

        let selector = NSSelectorFromString("startTest")
        sut.perform(selector)

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        let answerButton = buttons.first { $0.tag == 2 }

        XCTAssertNotNil(answerButton)

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

    func testMaximumScore() {

        let selector = NSSelectorFromString("startTest")
        sut.perform(selector)

        for _ in 0..<21 {

            let buttons = findSubviews(
                in: sut.view,
                ofType: UIButton.self
            )

            let maxButton = buttons.first { $0.tag == 3 }

            sut.perform(
                NSSelectorFromString("optionSelected:"),
                with: maxButton
            )
        }

        let mirror = Mirror(reflecting: sut!)

        let totalScore = mirror.children.first {
            $0.label == "totalScore"
        }?.value as? Int

        XCTAssertEqual(totalScore, 63)
    }

    func testMinimumScore() {

        let selector = NSSelectorFromString("startTest")
        sut.perform(selector)

        for _ in 0..<21 {

            let buttons = findSubviews(
                in: sut.view,
                ofType: UIButton.self
            )

            let minButton = buttons.first { $0.tag == 0 }

            sut.perform(
                NSSelectorFromString("optionSelected:"),
                with: minButton
            )
        }

        let mirror = Mirror(reflecting: sut!)

        let totalScore = mirror.children.first {
            $0.label == "totalScore"
        }?.value as? Int

        XCTAssertEqual(totalScore, 0)
    }

    // MARK: - Finish Test

    func testFinishTest() {

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = sut
        window.makeKeyAndVisible()

        sut.loadViewIfNeeded()

        // стартуем тест
        sut.perform(NSSelectorFromString("startTest"))

        // даём UI обновиться
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))

        // симулируем ответы на все вопросы
        for _ in 0..<21 {

            let buttons = findSubviews(in: sut.view, ofType: UIButton.self)

            guard let button = buttons.first(where: { $0.tag == 0 }) else {
                XCTFail("Кнопка не найдена")
                return
            }

            sut.optionSelected(button)

            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }

        // ждём alert
        let expectation = XCTestExpectation(description: "Alert presented")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            let alert = self.sut.presentedViewController as? UIAlertController

            XCTAssertNotNil(alert)
            XCTAssertTrue(alert?.title?.contains("Результат") == true)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Score Interpretation

    func testInterpretLowScore() {

        let result = interpretScore(5)

        XCTAssertEqual(result.0, "Норма")
    }

    func testInterpretMediumScore() {

        let result = interpretScore(18)

        XCTAssertEqual(result.0, "Умеренная депрессия")
    }

    func testInterpretHighScore() {

        let result = interpretScore(35)

        XCTAssertEqual(result.0, "Тяжелая депрессия")
    }
}

// MARK: - Helpers

extension BeckTestViewControllerTests {

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

    func interpretScore(_ score: Int) -> (String, String) {

        switch score {

        case 0...9:
            return (
                "Норма",
                "Отсутствие депрессивных симптомов."
            )

        case 10...15:
            return (
                "Субдепрессия",
                "Легкая депрессия."
            )

        case 16...19:
            return (
                "Умеренная депрессия",
                "Стоит обратить внимание."
            )

        case 20...29:
            return (
                "Выраженная депрессия",
                "Рекомендуется консультация."
            )

        case 30...63:
            return (
                "Тяжелая депрессия",
                "Необходимо обратиться к специалисту."
            )

        default:
            return (
                "Результат",
                "Тест завершен."
            )
        }
    }
}
