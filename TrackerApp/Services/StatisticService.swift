//
//  StatisticService.swift
//  TrackerApp
//
//  Created by Данил on 21/11/2026.
//

import Foundation

final class StatisticService {
  static let shared = StatisticService()
  
  private let defaults = UserDefaults.standard
  private enum Key {
    static let countComplitedTrackers = "countComplitedTrackers"
    static let bestRange = "bestRange"
    static let countBestDays = "countBestDays"
    static let averageComplitedTrackers = "averageComplitedTrackers"
  }
  
  private init() {}
  
  var countComplitedTrackers: Int {
    get {
      defaults.integer(forKey: Key.countComplitedTrackers)
    }
    set {
      defaults.set(newValue, forKey: Key.countComplitedTrackers)
    }
  }
  
  var bestRange: Int {
    get {
      defaults.integer(forKey: Key.bestRange)
    }
    set {
      defaults.set(newValue, forKey: Key.bestRange)
    }
  }
  
  var countBestDays: Int {
    get {
      defaults.integer(forKey: Key.countBestDays)
    }
    set {
      defaults.set(newValue, forKey: Key.countBestDays)
    }
  }
  
  var averageComplitedTrackers: Int {
    get {
      defaults.integer(forKey: Key.averageComplitedTrackers)
    }
    set {
      defaults.set(newValue, forKey: Key.averageComplitedTrackers)
    }
  }
}
