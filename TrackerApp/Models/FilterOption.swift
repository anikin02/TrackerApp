//
//  FilterOption.swift
//  TrackerApp
//
//  Created by Данил on 22/11/2026.
//

enum FilterOption: Int, CaseIterable {
  case showAllTrackers = 0
  case showTodayTrackers = 1
  case showComplitedTrackers = 2
  case showUncomplitedTrackers = 3
  
  var title: String {
    switch self {
      case .showAllTrackers:
        return "Все трекеры"
      case .showTodayTrackers:
        return "Трекеры на сегодня"
      case .showComplitedTrackers:
        return "Завершенные"
      case .showUncomplitedTrackers:
        return "Не завершенные"
    }
  }
  
  static var sortedByRawValue: [FilterOption] {
    allCases.sorted { $0.rawValue < $1.rawValue }
  }
}
