//
//  TabBarController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 26.11.2023.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerViewController = UINavigationController(rootViewController: TrackerViewController())
        trackerViewController.tabBarItem = UITabBarItem(
            title: "tabbar_trackers".localized,
            image: UIImage(named: "trackerBarLogo"),
            selectedImage: nil
        )
        
        let statisticViewController = UINavigationController(rootViewController: StatisticViewController())
        statisticViewController.tabBarItem = UITabBarItem(
            title: "tabbar_statistics".localized,
            image: UIImage(named: "statisticBarLogo"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackerViewController, statisticViewController]
    }
}
