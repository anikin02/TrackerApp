//
//  FilterSavingService.swift
//  TrackerApp
//
//  Created by Данил on 21/11/2026.
//

import Foundation

final class FilterSavingService {
  static let shared = FilterSavingService()
  
  private let defaults = UserDefaults.standard
  private enum Key {
    static let filterOption = "filterOption"
  }
  
  private init() {}
  
  var savedFilter: FilterOption {
    get {
      let rawValue = defaults.integer(forKey: Key.filterOption)
      guard let option = FilterOption(rawValue: rawValue) else {
        return .showAllTrackers
      }
      return option
    }
    set {
      defaults.set(newValue.rawValue, forKey: Key.filterOption)
    }
  }
  
  func resetFilter() {
    defaults.removeObject(forKey: Key.filterOption)
  }
}
