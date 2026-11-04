//
//  SplashViewController.swift
//  TrackerApp
//
//  Created by Данил on 03/11/2026.
//

import UIKit

final class SplashViewController: UIViewController {
  // MARK: - UI Elements
  private var logoImage: UIImageView = .init()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    switchToTabBarController()
  }
  
  // MARK: - Private Methods
  private func configUI() {
    view.backgroundColor = .blueYP
    configLogo()
  }
  
  private func configLogo() {
    logoImage.translatesAutoresizingMaskIntoConstraints = false
    logoImage.image = UIImage(resource: .logo)
    
    view.addSubview(logoImage)
    
    NSLayoutConstraint.activate([
      logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      logoImage.heightAnchor.constraint(equalToConstant: 94),
      logoImage.widthAnchor.constraint(equalToConstant: 91)
    ])
  }
  
  private func switchToTabBarController() {
    let window = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    
    let tabBarController = TabBarController()
    
    window?.rootViewController = tabBarController
  }
}

