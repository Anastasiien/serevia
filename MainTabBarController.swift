//
//  MainTabBarController.swift
//  Mindfulness
//
//  Created by Анастасия Бердюгина on 07.11.25.
//  Edited by ekatizzz on 07.04.26.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupTabBarAppearance()
    }
    
    private func setupTabs() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        let meditateVC = UINavigationController(rootViewController: MeditateViewController())
        let aiVC = UINavigationController(rootViewController: AIViewController())
        let journalVC = UINavigationController(rootViewController: JournalViewController())
        let exploreVC = UINavigationController(rootViewController: ExploreViewController())

        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        meditateVC.tabBarItem = UITabBarItem(title: "Meditate", image: UIImage(systemName: "apple.meditate"), selectedImage: UIImage(systemName: "apple.meditate"))
        
        aiVC.tabBarItem = UITabBarItem(title: "AI", image: UIImage(systemName: "sparkles"), selectedImage: UIImage(systemName: "sparkles.fill"))
        
        journalVC.tabBarItem = UITabBarItem(title: "Journal", image: UIImage(systemName: "book"), selectedImage: UIImage(systemName: "book.fill"))
        
        exploreVC.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "leaf"), selectedImage: UIImage(systemName: "leaf.fill"))

        viewControllers = [homeVC, meditateVC, aiVC, journalVC, exploreVC]
    }

    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.background

        // убираем фон-индикатор под выбранной иконкой
        appearance.selectionIndicatorTintColor = .clear
        appearance.selectionIndicatorImage = UIImage()

        // цвет иконок и текста
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: AppColors.lightText]
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: AppColors.primary]

        appearance.stackedLayoutAppearance.normal.iconColor = AppColors.lightText
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        appearance.stackedLayoutAppearance.selected.iconColor = AppColors.primary
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.tintColor = AppColors.primary
        tabBar.unselectedItemTintColor = AppColors.lightText
    }
}
