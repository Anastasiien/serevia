//
//  SceneDelegate.swift
//  Mindfulness
//
//  Created by Анастасия Бердюгина on 07.11.25.
//  Edited by ekatizzz on 15.04.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let accentColor = UIColor(red: 0.58, green: 0.46, blue: 0.42, alpha: 1)
        UINavigationBar.appearance().tintColor = accentColor
        
        let window = UIWindow(windowScene: windowScene)
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        if isLoggedIn {
            window.rootViewController = MainTabBarController()
        } else {
            window.rootViewController = AuthViewController()
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
