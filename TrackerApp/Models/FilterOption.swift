//
//  FilterOption.swift
//  TrackerApp
//
//  Created by Данил on 22/11/2026.
//

import Foundation

enum FilterOption: Int, CaseIterable {
  case showAllTrackers = 0
  case showTodayTrackers = 1
  case showComplitedTrackers = 2
  case showUncomplitedTrackers = 3
  
  var title: String {
    switch self {
      case .showAllTrackers:
        return NSLocalizedString("allTrackersFilterTitle", comment: "")
      case .showTodayTrackers:
        return NSLocalizedString("todayTrackersFilterTitle", comment: "")
      case .showComplitedTrackers:
        return NSLocalizedString("completedTrackersFilterTitle", comment: "")
      case .showUncomplitedTrackers:
        return NSLocalizedString("uncompletedTrackersFilterTitle", comment: "")
    }
  }
  
  static var sortedByRawValue: [FilterOption] {
    allCases.sorted { $0.rawValue < $1.rawValue }
  }
}
