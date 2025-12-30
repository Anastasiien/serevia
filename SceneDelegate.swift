//
//  SceneDelegate.swift
//  Mindfulness
//
//  Created by Анастасия Бердюгина on 07.11.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let viewController = MainTabBarController()
        window.rootViewController = viewController
        self.window = window
        window.makeKeyAndVisible()
    }
}


