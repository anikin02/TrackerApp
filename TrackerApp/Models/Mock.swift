//
//  Mock.swift
//  TrackerApp
//
//  Created by Данил on 05/11/2026.
//

import Foundation

import Foundation

enum Mock {
  static let water = Tracker(
    id: UUID(),
    name: "Пить воду",
    hexColor: HexColorSection.color1.rawValue,
    emoji: "F",
    schedule: Set(WeekDay.allCases)
  )
  static let workout = Tracker(
    id: UUID(),
    name: "Тренировка",
    hexColor: HexColorSection.color2.rawValue,
    emoji: "🐯",
    schedule: [.monday, .wednesday, .friday]
  )
  static let reading = Tracker(
    id: UUID(),
    name: "Чтение книги",
    hexColor: HexColorSection.color3.rawValue,
    emoji: "🍎",
    schedule: [.tuesday, .thursday, .saturday]
  )
  static let cleaning = Tracker(
    id: UUID(),
    name: "Убрать квартиру",
    hexColor: HexColorSection.color4.rawValue,
    emoji: "🍎",
    schedule: [.saturday]
  )
  static let cooking = Tracker(
    id: UUID(),
    name: "Приготовить еду",
    hexColor: HexColorSection.color5.rawValue,
    emoji: "🍎",
    schedule: [.sunday, .wednesday]
  )
  static let cat = Tracker(
    id: UUID(),
    name: "Кошка заслонила камеру на созвоне",
    hexColor: HexColorSection.color6.rawValue,
    emoji: "🐱",
    schedule: [.monday]
  )
  static let tickets = Tracker(
    id: UUID(),
    name: "Купить билеты",
    hexColor: HexColorSection.color7.rawValue,
    emoji: "🍕",
    schedule: Set(WeekDay.allCases),
    isRegular: false
  )
  static let categories: [TrackerCategory] = [
    TrackerCategory(title: "Здоровье", trackers: [water, workout]),
    TrackerCategory(title: "Саморазвитие", trackers: [reading]),
    TrackerCategory(title: "Радостные мелочи", trackers: [cat]),
    TrackerCategory(title: "Дела", trackers: [tickets, cleaning, cooking])
  ]
  static let completedTrackers: [TrackerRecord] = {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

    return [
      TrackerRecord(trackerId: water.id, date: today),
      TrackerRecord(trackerId: water.id, date: yesterday),
      TrackerRecord(trackerId: water.id, date: twoDaysAgo),
      TrackerRecord(trackerId: workout.id, date: yesterday),
      TrackerRecord(trackerId: reading.id, date: twoDaysAgo)
    ]
  }()
}

enum HexColorSection: String, CaseIterable {
  case color1  = "#FD4C49"
  case color2  = "#35347C"
  case color3  = "#FF674D"
  case color4  = "#FF99CC"
  case color5  = "#F6C48B"
  case color6  = "#7994F5"
  case color7  = "#832CF1"
  case color8  = "#AD56DA"
  case color9  = "#8D72E6"
  case color10 = "#2FD058"
  case color11 = "#FF881E"
  case color12 = "#007BFA"
  case color13 = "#6E44FE"
  case color14 = "#33CF69"
  case color15 = "#E66DD4"
  case color16 = "#F9D4D4"
  case color17 = "#34A7FE"
  case color18 = "#46E69D"
}

