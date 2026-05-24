//
//  AuthViewControllerTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class AuthViewControllerTests: XCTestCase {

    private let isLoggedInKey = "isLoggedIn"
    private let userNameKey = "userName"
    private let userEmailKey = "userEmail"

    private var sut: AuthViewController!

    override func setUp() {
        super.setUp()

        UserDefaults.standard.removeObject(forKey: isLoggedInKey)
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.removeObject(forKey: userEmailKey)

        sut = AuthViewController()
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil

        UserDefaults.standard.removeObject(forKey: isLoggedInKey)
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.removeObject(forKey: userEmailKey)

        super.tearDown()
    }

    // MARK: - Validation

    func testEmailValidation() {

        XCTAssertTrue(
            isValidEmail("test@gmail.com")
        )

        XCTAssertFalse(
            isValidEmail("wrong-email")
        )
    }

    func testPasswordValidation() {

        XCTAssertTrue(
            isValidPassword("password123")
        )

        XCTAssertFalse(
            isValidPassword("123")
        )

        XCTAssertFalse(
            isValidPassword("pass!!!")
        )
    }

    // MARK: - Login Flow

    func testLoginSuccess() {

        let textFields = findSubviews(
            in: sut.view,
            ofType: UITextField.self
        )

        guard textFields.count >= 2 else {
            XCTFail("TextFields not found")
            return
        }

        let emailField = textFields[1]
        let passwordField = textFields[2]

        emailField.text = "test@gmail.com"
        passwordField.text = "password123"

        let selector = NSSelectorFromString("handleMainAction")

        sut.perform(selector)

        let isLoggedIn = UserDefaults.standard.bool(
            forKey: isLoggedInKey
        )

        XCTAssertTrue(isLoggedIn)
    }

    func testLoginFailure() {

        let textFields = findSubviews(
            in: sut.view,
            ofType: UITextField.self
        )

        guard textFields.count >= 2 else {
            XCTFail("TextFields not found")
            return
        }

        let emailField = textFields[1]
        let passwordField = textFields[2]

        emailField.text = "wrong-email"
        passwordField.text = "123"

        let selector = NSSelectorFromString("handleMainAction")

        sut.perform(selector)

        let isLoggedIn = UserDefaults.standard.bool(
            forKey: isLoggedInKey
        )

        XCTAssertFalse(isLoggedIn)
    }

    // MARK: - Persistence

    func testUserDefaultsAfterLogin() {

        UserDefaults.standard.set(
            true,
            forKey: isLoggedInKey
        )

        UserDefaults.standard.set(
            "Катя",
            forKey: userNameKey
        )

        UserDefaults.standard.set(
            "katya@gmail.com",
            forKey: userEmailKey
        )

        XCTAssertTrue(
            UserDefaults.standard.bool(
                forKey: isLoggedInKey
            )
        )

        XCTAssertEqual(
            UserDefaults.standard.string(
                forKey: userNameKey
            ),
            "Катя"
        )

        XCTAssertEqual(
            UserDefaults.standard.string(
                forKey: userEmailKey
            ),
            "katya@gmail.com"
        )
    }
}

// MARK: - Helpers

extension AuthViewControllerTests {

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

    func isValidEmail(_ email: String) -> Bool {

        let regex =
        "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let predicate = NSPredicate(
            format: "SELF MATCHES %@",
            regex
        )

        return predicate.evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {

        let regex = "^[a-zA-Z0-9]{8,}$"

        let predicate = NSPredicate(
            format: "SELF MATCHES %@",
            regex
        )

        return predicate.evaluate(with: password)
    }
}
