//
//  WeekDay.swift
//  TrackerApp
//
//  Created by Данил on 08/11/2026.
//

import Foundation

enum WeekDay: Int, CaseIterable, Encodable, Decodable {
  case sunday = 1
  case monday = 2
  case tuesday = 3
  case wednesday = 4
  case thursday = 5
  case friday = 6
  case saturday = 7
}

extension WeekDay {
  var title: String {
    switch self {
      case .monday: return NSLocalizedString("mondayTitle", comment: "")
      case .tuesday: return NSLocalizedString("tuesdayTitle", comment: "")
      case .wednesday: return NSLocalizedString("wednesdayTitle", comment: "")
      case .thursday: return NSLocalizedString("thursdayTitle", comment: "")
      case .friday: return NSLocalizedString("fridayTitle", comment: "")
      case .saturday: return NSLocalizedString("saturdayTitle", comment: "")
      case .sunday: return NSLocalizedString("sundayTitle", comment: "")
    }
  }
  
  var shortTitle: String {
    switch self {
      case .monday: return NSLocalizedString("mondayShortTitle", comment: "")
      case .tuesday: return NSLocalizedString("mondayShortTitle", comment: "")
      case .wednesday: return NSLocalizedString("mondayShortTitle", comment: "")
      case .thursday: return NSLocalizedString("mondayShortTitle", comment: "")
      case .friday: return NSLocalizedString("mondayShortTitle", comment: "")
      case .saturday: return NSLocalizedString("mondayShortTitle", comment: "")
      case .sunday: return NSLocalizedString("mondayShortTitle", comment: "")
    }
  }
  
  static let orderedWeek: [WeekDay] = [
    .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
  ]
  
  static func scheduleDescription(for days: Set<WeekDay>) -> String {
    if days.count == 7 {
      return NSLocalizedString("everyDayTitle", comment: "")
    } else {
      return days
        .filter { days.contains($0) }
        .map { $0.shortTitle }
        .joined(separator: ", ")
    }
  }
}
