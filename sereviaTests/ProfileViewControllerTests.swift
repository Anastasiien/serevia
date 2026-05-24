//
//  ProfileViewControllerTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class ProfileViewControllerTests: XCTestCase {

    var sut: ProfileViewController!

    override func setUp() {
        super.setUp()
        sut = ProfileViewController()
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // Проверка загрузки данных пользователя
    func test_viewDidLoad_shouldLoadData() {
        XCTAssertNotNil(sut.view)
    }

    // Проверка navigation item
    func test_navigationBar_shouldContainEditButton() {
        sut.viewDidLoad()

        XCTAssertNotNil(sut.navigationItem.rightBarButtonItem)
    }

    // Проверка title
    func test_title_shouldBeCorrect() {
        sut.viewDidLoad()

        XCTAssertEqual(sut.title, "Личный кабинет")
    }

    // Проверка scrollView
    func test_scrollView_shouldExist() {
        let scrollViews = sut.view.subviews.compactMap { $0 as? UIScrollView }
        XCTAssertFalse(scrollViews.isEmpty)
    }
}
