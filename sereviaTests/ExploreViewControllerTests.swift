//
//  ExploreViewControllerTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class ExploreViewControllerTests: XCTestCase {

    var sut: ExploreViewController!

    override func setUp() {
        super.setUp()
        sut = ExploreViewController()
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // Проверка загрузки view
    func test_view_shouldLoad() {
        XCTAssertNotNil(sut.view)
    }

    // Проверка scrollView
    func test_scrollView_shouldExist() {
        let scrollViews = sut.view.subviews.compactMap { $0 as? UIScrollView }
        XCTAssertFalse(scrollViews.isEmpty)
    }

    // Проверка background color
    func test_backgroundColor_shouldBeSet() {
        XCTAssertNotNil(sut.view.backgroundColor)
    }

    // Проверка отображения контента
    func test_contentView_shouldContainSubviews() {
        XCTAssertFalse(sut.view.subviews.isEmpty)
    }
}
