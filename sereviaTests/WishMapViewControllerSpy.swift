//
//  WishMapViewControllerSpy.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

@testable import serevia
import UIKit

final class WishMapEditorViewControllerSpy: WishMapEditorViewController {

    var didPresentImagePicker = false
    var presentedVC: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {

        presentedVC = viewControllerToPresent

        if viewControllerToPresent is UIImagePickerController {
            didPresentImagePicker = true
        }

        super.present(viewControllerToPresent,
                      animated: flag,
                      completion: completion)
    }
}
