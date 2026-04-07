//
//  PersonSuggestionCell.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }
    
    private func setupTabs() {
        // Tab 1: Photos
        let photoListVC = PhotoListBuilder().build()
        let photosNav = UINavigationController(rootViewController: photoListVC)
        photosNav.tabBarItem = UITabBarItem(title: AppStrings.tabPhotos, image: UIImage(systemName: "photo.on.rectangle.angled"), tag: 0)
        
        // Tab 2: People
        let peopleListVC = PeopleListBuilder.build()
        let peopleNav = UINavigationController(rootViewController: peopleListVC)
        peopleNav.tabBarItem = UITabBarItem(title: AppStrings.tabPeople, image: UIImage(systemName: "person.2.fill"), tag: 1)
        
        viewControllers = [photosNav, peopleNav]
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .systemBlue
    }
}
