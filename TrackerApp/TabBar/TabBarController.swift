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
    configTabBarAppearance()
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
  
  private func configTabBarAppearance() {
    tabBar.tintColor = .blueYP
    tabBar.unselectedItemTintColor = .grayYP
    //tabBar.backgroundColor = .whiteYP
  }
}
