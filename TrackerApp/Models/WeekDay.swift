//
//  WeekDay.swift
//  TrackerApp
//
//  Created by Данил on 08/11/2026.
//

enum WeekDay: Int, CaseIterable {
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
      case .monday: return "Понедельник"
      case .tuesday: return "Вторник"
      case .wednesday: return "Среда"
      case .thursday: return "Четверг"
      case .friday: return "Пятница"
      case .saturday: return "Суббота"
      case .sunday: return "Воскресенье"
    }
  }
  
  var shortTitle: String {
    switch self {
      case .monday: return "Пн"
      case .tuesday: return "Вт"
      case .wednesday: return "Ср"
      case .thursday: return "Чт"
      case .friday: return "Пт"
      case .saturday: return "Сб"
      case .sunday: return "Вс"
    }
  }
  
  static let orderedWeek: [WeekDay] = [
    .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
  ]
  
  static func scheduleDescription(for days: Set<WeekDay>) -> String {
    if days.count == 7 {
      return "Каждый день"
    } else {
      return days
        .filter { days.contains($0) }
        .map { $0.shortTitle }
        .joined(separator: ", ")
    }
  }
}
