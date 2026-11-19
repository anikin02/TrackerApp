//
//  FirstLaunchService.swift
//  TrackerApp
//
//  Created by Данил on 16/11/2026.
//

import Foundation

final class FirstLaunchService {
  static let shared = FirstLaunchService()
  
  private let defaults = UserDefaults.standard
  private enum Key {
    static let hasLaunchedBefore = "hasLaunchedBefore"
  }
  
  private init() {}
  
  var hasLaunchedBefore: Bool {
    get { defaults.bool(forKey: Key.hasLaunchedBefore) }
    set { defaults.set(newValue, forKey: Key.hasLaunchedBefore) }
  }
}
