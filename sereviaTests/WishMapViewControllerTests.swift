//
//  WishMapViewControllerTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class WishMapViewControllerTests: XCTestCase {

    private var sut: WishMapEditorViewController!
    private let storageKey = "wishMapImage"

    override func setUp() {
        super.setUp()

        UserDefaults.standard.removeObject(forKey: storageKey)

        sut = WishMapEditorViewController()
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: storageKey)

        sut = nil

        super.tearDown()
    }

    // MARK: - UI

    func testSaveButtonExists() {

        let buttons = findSubviews(
            in: sut.view,
            ofType: UIButton.self
        )

        let containsSaveButton = buttons.contains {
            $0.currentTitle == "Сохранить"
        }

        XCTAssertTrue(containsSaveButton)
    }

    // MARK: - Image Picker

    func testImagePickerOpens() {

        let sut = WishMapEditorViewControllerSpy()

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = sut
        window.makeKeyAndVisible()

        sut.loadViewIfNeeded()

        sut.addImage()

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))

        XCTAssertTrue(sut.didPresentImagePicker)
        XCTAssertTrue(sut.presentedVC is UIImagePickerController)
    }
    
    // MARK: - Image Restore

    func testImageRestoresAfterReload() {

        let image = UIImage(systemName: "star")!
        let data = image.jpegData(compressionQuality: 1.0)!

        UserDefaults.standard.set(data, forKey: storageKey)

        let vc = WishMapEditorViewController()
        vc.loadViewIfNeeded()

        vc.view.layoutIfNeeded()
        vc.viewDidLayoutSubviews()

        let imageViews = findSubviews(
            in: vc.view,
            ofType: UIImageView.self
        )

        let restoredImageExists = imageViews.contains {
            $0.tag == 999
        }

        XCTAssertTrue(restoredImageExists)
    }

    // MARK: - Canvas

    func testCanvasAcceptsImage() {

        let image = UIImage(systemName: "heart")!

        let picker = UIImagePickerController()

        let info: [UIImagePickerController.InfoKey: Any] = [
            .originalImage: image
        ]

        sut.imagePickerController(
            picker,
            didFinishPickingMediaWithInfo: info
        )

        let imageViews = findSubviews(
            in: sut.view,
            ofType: UIImageView.self
        )

        XCTAssertFalse(imageViews.isEmpty)
    }
}

// MARK: - Helpers

extension WishMapViewControllerTests {

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
}
