//
//  SceneDelegate.swift
//  TrackerApp
//
//  Created by Данил on 03/11/2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = SplashViewController()
    window?.makeKeyAndVisible()
  }
}

