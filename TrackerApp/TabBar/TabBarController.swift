//
//  TabBarController.swift
//  TrackerApp
//
//  Created by Данил on 04/11/2026.
//

import UIKit

final class TabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabBarItems()
    configureTabBarAppearance()
  }
  
  private func setupTabBarItems() {
    let trackersNavigationController = UINavigationController(
      rootViewController: TrackersListViewController()
    )
    
    trackersNavigationController.tabBarItem = UITabBarItem(
      title: "Трекеры",
      image: UIImage(resource: .trackers),
      selectedImage: nil
    )
    
    let statisticsViewController = StatisticsViewController()
    
    statisticsViewController.tabBarItem = UITabBarItem(
      title: "Статистика",
      image: UIImage(resource: .stats),
      selectedImage: nil
    )
    
    self.viewControllers = [trackersNavigationController,
                            statisticsViewController]
  }
  
  private func configureTabBarAppearance() {
    tabBar.tintColor = .blueYP
    tabBar.unselectedItemTintColor = .grayYP
    
    if #unavailable(iOS 26.0) {
      tabBar.backgroundColor = .whiteYP
    }
    
    let appearance = UITabBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.shadowColor = .grayYP
    tabBar.standardAppearance = appearance
    tabBar.scrollEdgeAppearance = appearance
  }
}
