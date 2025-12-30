//
//  MainTabBarController.swift
//  Mindfulness
//
//  Created by Анастасия Бердюгина on 07.11.25.
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

        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        meditateVC.tabBarItem = UITabBarItem(title: "Meditate", image: UIImage(systemName: "apple.meditate"), tag: 1)
        aiVC.tabBarItem = UITabBarItem(title: "AI", image: UIImage(systemName: "sparkles"), tag: 2)
        journalVC.tabBarItem = UITabBarItem(title: "Journal", image: UIImage(systemName: "book"), tag: 3)
        exploreVC.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "leaf"), tag: 4)

        viewControllers = [homeVC, meditateVC, aiVC, journalVC, exploreVC]
        selectedIndex = 0
    }

    
    private func setupTabBarAppearance() {
        tabBar.barTintColor = AppColors.background
        tabBar.tintColor = AppColors.primary
        tabBar.unselectedItemTintColor = AppColors.lightText
    }
}

